package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer/types"
	"github.com/aws/aws-sdk-go/aws"
)

type Response struct {
	Message string `json:"msg"`
	Time    string `json:"time"`
}

type SlackMessage struct {
	Text string `json:"text"`
}

func handleRequest(ctx context.Context) (*Response, error) {
	// Get the start and end dates of the current month
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	endOfMonth := startOfMonth.AddDate(0, 1, -1)

	// Load AWS configuration
	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		return nil, fmt.Errorf("unable to load SDK config: %v", err)
	}

	// Create Cost Explorer client
	ce := costexplorer.NewFromConfig(cfg)

	// Set parameters for cost retrieval
	input := &costexplorer.GetCostAndUsageInput{
		TimePeriod: &types.DateInterval{
			Start: aws.String(startOfMonth.Format("2006-01-02")),
			End:   aws.String(endOfMonth.Format("2006-01-02")),
		},
		Granularity: types.GranularityMonthly,
		Metrics:     []string{"UnblendedCost"},
	}

	// Get cost information
	result, err := ce.GetCostAndUsage(ctx, input)
	if err != nil {
		return nil, fmt.Errorf("failed to get cost and usage: %v", err)
	}

	if len(result.ResultsByTime) == 0 {
		return nil, fmt.Errorf("no cost data available")
	}

	cost := result.ResultsByTime[0].Total["UnblendedCost"]
	message := fmt.Sprintf("AWS usage fees for this month: %s %s", *cost.Amount, *cost.Unit)

	// Create Slack message
	slackMsg := SlackMessage{Text: message}
	jsonMsg, err := json.Marshal(slackMsg)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal slack message: %v", err)
	}

	// Get Slack webhook URL from environment variables
	webhookURL := os.Getenv("SLACK_WEBHOOK_URL")
	if webhookURL == "" {
		return nil, fmt.Errorf("SLACK_WEBHOOK_URL is not set")
	}

	// Slackへの通知
	resp, err := http.Post(webhookURL, "application/json", bytes.NewBuffer(jsonMsg))
	if err != nil {
		return nil, fmt.Errorf("failed to send slack notification: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("slack notification failed with status: %d", resp.StatusCode)
	}

	res := Response{
		Message: "Send notification to Slack",
		Time:    time.Now().String(),
	}
	return &res, nil
}

func main() {
	lambda.Start(handleRequest)
}
