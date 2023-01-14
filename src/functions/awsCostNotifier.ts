import { IncomingWebhook } from '@slack/webhook'
import moment from 'moment';
import AWS from 'aws-sdk'

export async function handler() {
    const now = moment();
    const start = now.startOf('month').format('YYYY-MM-DD');
    const end = now.endOf('month').format('YYYY-MM-DD');

    const costExplorer = new AWS.CostExplorer({ region: 'us-east-1' })
    const params = {
        TimePeriod: {
            Start: start,
            End: end
        },
        Granularity: 'MONTHLY',
        Metrics: ['UnblendedCost']
    }
    const costAndUsage = await costExplorer.getCostAndUsage(params).promise()
    const UnblendedCost = costAndUsage.ResultsByTime[0].Total.UnblendedCost;

    const slackWebhook = new IncomingWebhook(process.env.SLACK_WEBHOOK_URL)
    await slackWebhook.send(`AWS usage fees for this month: ${UnblendedCost.Amount} ${UnblendedCost.Unit}`)
};

