const AWS = require('aws-sdk');

const elbv2 = new AWS.ELBv2();
const ecs = new AWS.ECS();
const sns = new AWS.SNS();

exports.up = async (event, context) => {
    console.log(JSON.stringify({event, context}, null, 2));

    if (event.path === '/polling') {
        return {
            "statusCode": 503,
            "statusDescription": "503 Service Unavailable",
            "isBase64Encoded": false,
            "headers": { "Content-Type": "text/plain" },
            "body": "503 Service Unavailable"
        };
    }

    await ecs.updateService({
        cluster: process.env.cluster_arn,
        service: process.env.service_name,
        desiredCount: 1,
    }).promise();

    await elbv2.setRulePriorities({
        RulePriorities: [{
            Priority: 1,
            RuleArn: process.env.listener_rule_arn,
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

exports.down = async (event, context) => {
    console.log(JSON.stringify({event, context}, null, 2));

    const topic = pluckSnsTopicArn(event);
    console.log(JSON.stringify({topic}, null, 2));
    if (!topic) {
        return;
    }

    const tags = await fetchSnsTopicTags(topic);
    console.log(JSON.stringify({tags}, null, 2));

    const cluster_arn = tags['ecs:cluster-arn']
    const service_name = tags['ecs:service-name']
    const listener_rule_arn = tags['elb:listener-rule-arn']

    await elbv2.setRulePriorities({
        RulePriorities: [{
            Priority: 999,
            RuleArn: listener_rule_arn,
        }],
    }).promise();

    await ecs.updateService({
        cluster: cluster_arn,
        service: service_name,
        desiredCount: 0,
    }).promise();

    return {};
};
