# aws cost notifier

Daily slack notifications of AWS monthly costs.

## Require

- [Node.js](https://nodejs.org/en/)
- [serverless](https://www.npmjs.com/package/serverless)

## Configuration

Set the following variable for Slack webhook URL in AWS parameter store.

```
SLACK_WEBHOOK_URL_COST_NOTIFIER
```

## Install dependencies

```
npm install
```

## Select AWS Profile

```
export AWS_PROFILE={YOUR PROFILE}
```

## Run locally

```
npm run send
```

## Deploy

```
serverless deploy
```
