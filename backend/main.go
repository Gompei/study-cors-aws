package main

import (
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(handler)
}

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var body string

	switch request.HTTPMethod {
	case "GET":
		body = "get method"
	case "POST":
		body = "post method"
	}

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers: map[string]string{
			// 今回はサンプルの為、すべてのオリジンを許可しています。
			// 本番・ステージング環境では非推奨です。
			"Access-Control-Allow-Origin":  "*",
			"Access-Control-Allow-Methods": "GET,POST,OPTIONS",
			"Access-Control-Allow-Headers": "Content-Type",
			"Content-Type":                 "application/json; charset=utf-8",
		},
		Body: body,
	}, nil
}
