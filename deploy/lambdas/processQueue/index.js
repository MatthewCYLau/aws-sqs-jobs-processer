const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const REGION = "us-east-1";

const dbclient = new DynamoDBClient({ region: REGION });

const fibonacci = (num) => {
  const arr = [0, 1];

  if (num < 3) {
    return arr.slice(0, num);
  }

  for (let i = 1; i < num - 1; i++) {
    const next = arr[i] + arr[i - 1];
    arr.push(next);
  }
  return arr;
};

exports.handler = async (event) => {
  const promises = event.Records.map((record) => {
    const body = JSON.parse(record.body);
    const num = body.data;
    const results = fibonacci(num);
    const params = {
      TableName: "jobs",
      Item: {
        jobId: { S: record.messageId },
        results: {
          L: results.map((x) => {
            return { N: x.toString() };
          }),
        },
        created: { S: new Date().toISOString() },
      },
    };
    const data = dbclient.send(new PutItemCommand(params));
    return data;
  });

  return Promise.all(promises);
};
