#!/bin/bash

npm i && zip -r processQueue.zip index.js node_modules && \
aws s3 cp processQueue.zip \
    s3://matlau-lambdas-bucket/v1.0.0/processQueue.zip && \
aws lambda update-function-code \
    --function-name ProcessQueueMessage \
    --s3-bucket matlau-lambdas-bucket \
    --s3-key v1.0.0/processQueue.zip