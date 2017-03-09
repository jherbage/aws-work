#!/bin/bash
# zip up the function
rm function.zip
aws lambda delete-function --function-name demoLambdaHelloWorld
aws iam delete-role --role-name 'demo-lambda'
zip function.zip function.js
aws iam create-role --role-name 'demo-lambda' --assume-role-policy-document '{ "Version": "2012-10-17", "Statement": [ { "Action": "sts:AssumeRole", "Effect": "Allow", "Principal": { "Service": "lambda.amazonaws.com" } } ] }'
export arn=`aws iam get-role --role-name 'demo-lambda' | grep "Arn" |cut -d":" -f2- | sed -e 's/[\" ]//g'`
aws lambda create-function --handler="function.handler" --role="$arn" --runtime nodejs4.3 --function-name demoLambdaHelloWorld --zip fileb://function.zip
