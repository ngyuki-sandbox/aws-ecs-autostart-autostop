const AWS = require('aws-sdk');

const elbv2 = new AWS.ELBv2();
const ecs = new AWS.ECS();
const ssm = new AWS.SSM();
const sns = new AWS.SNS();

function pluckSnsTopicArn(event) {
    const rec = event.Records[0];
    if (rec.EventSource !== 'aws:sns') {
        return null;
    }
    if (rec.Sns === undefined) {
        return null;
    }
    if (rec.Sns.Type !== 'Notification') {
        return null;
    }
    return rec.Sns.TopicArn;
}

async function fetchSnsTopicTags(topic) {
    const res = await sns.listTagsForResource({ ResourceArn: topic }).promise();
    return res.Tags.reduce((r, {Key, Value}) => {
        r[Key] = Value;
        return r;
    }, {})
}

async function fetchParameter(dns_name) {
    const parameter_prefix = process.env.parameter_prefix;
    const res = await ssm.getParameter({ Name: `${parameter_prefix}/${dns_name}` }).promise();
    const parameter = JSON.parse(res.Parameter.Value);
    return {
        cluster_arn: parameter.cluster_arn,
        service_name: parameter.service_name,
        listener_rule_arn: parameter.listener_rule_arn,
        listener_priority: parameter.listener_priority,
    };
}

exports.up = async (event, context) => {
    //console.log(JSON.stringify({event, context}, null, 2));

    if (event.path === '/polling') {
        return {
            "statusCode": 503,
            "statusDescription": "503 Service Unavailable",
            "isBase64Encoded": false,
            "headers": { "Content-Type": "text/plain" },
            "body": "503 Service Unavailable"
        };
    }

    const dns_name = event.headers.host;
    const parameter = await fetchParameter(dns_name);
    console.log(JSON.stringify({ parameter }, null, 2));

    await ecs.updateService({
        cluster: parameter.cluster_arn,
        service: parameter.service_name,
        desiredCount: 1,
    }).promise();

    await elbv2.setRulePriorities({
        RulePriorities: [{
            Priority: parameter.listener_priority,
            RuleArn: parameter.listener_rule_arn,
        }],
    }).promise();

    return {
        "statusCode": 200,
        "statusDescription": "200 OK",
        "isBase64Encoded": false,
        "headers": { "Content-Type": "text/html" },
        "body": `
            <h1>Waiting for environment to start.</h1>
            <script>
                setInterval(async () => {
                    const response = await fetch('/polling', { cache: 'no-store' });
                    if (response.status < 500) {
                        location.reload();
                    }
                    document.querySelector('h1').innerText += '.';
                }, 1000);
            </script>
        `
    };
};

exports.down = async (event, context) => {
    console.log(JSON.stringify({event, context}, null, 2));

    const topic = pluckSnsTopicArn(event);
    console.log(JSON.stringify({topic}, null, 2));
    if (!topic) {
        return;
    }

    const tags = await fetchSnsTopicTags(topic);
    console.log(JSON.stringify({tags}, null, 2));

    const dns_name = tags['dns-name'];
    const parameter = await fetchParameter(dns_name);
    console.log(JSON.stringify({ parameter }, null, 2));

    await elbv2.setRulePriorities({
        RulePriorities: [{
            Priority: parameter.listener_priority + 20000,
            RuleArn: parameter.listener_rule_arn,
        }],
    }).promise();

    await ecs.updateService({
        cluster: parameter.cluster_arn,
        service: parameter.service_name,
        desiredCount: 0,
    }).promise();

    return {};
};
