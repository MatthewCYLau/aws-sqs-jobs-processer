// Load the AWS SDK for Node.js
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

// Set the region
const REGION = "us-east-1";

// Create DynamoDB service object
const dbclient = new DynamoDBClient({ region: REGION });

exports.handler = async event => {
  const promises = event.Records.map(record => {
    const params = {
      TableName: "jobs",
      Item: {
        jobId: { S: record.messageId }
      }
    };
    const data = dbclient.send(new PutItemCommand(params));
    return data;
  });

  return Promise.all(promises);
};
