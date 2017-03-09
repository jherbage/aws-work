#!/bin/bash
# zip up the function
rm function.zip
aws lambda delete-function --function-name demoLambdaHelloWorldPython
aws iam get-role --role-name 'demo-lambda' | grep Arn
if [ $? -ne 0 ]; then
  aws iam create-role --role-name 'demo-lambda' --assume-role-policy-document '{ "Version": "2012-10-17", "Statement": [ { "Action": "sts:AssumeRole", "Effect": "Allow", "Principal": { "Service": "lambda.amazonaws.com" } } ] }'
fi

zip function.zip function.py

export arn=`aws iam get-role --role-name 'demo-lambda' | grep "Arn" |cut -d":" -f2- | sed -e 's/[\" ]//g'`

aws lambda create-function --handler="function.handler" --role="$arn" --runtime python2.7 --function-name demoLambdaHelloWorldPython --zip fileb://function.zip
