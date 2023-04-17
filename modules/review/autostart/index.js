const AWS = require('aws-sdk');

const elbv2 = new AWS.ELBv2();
const ecs = new AWS.ECS();

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

exports.down = async (event, context) => {
    console.log(JSON.stringify({event, context}, null, 2));

    await elbv2.setRulePriorities({
        RulePriorities: [{
            Priority: 999,
            RuleArn: process.env.listener_rule_arn,
        }],
    }).promise();

    await ecs.updateService({
        cluster: process.env.cluster_arn,
        service: process.env.service_name,
        desiredCount: 0,
    }).promise();

    return {};
};
