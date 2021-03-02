// Load the AWS SDK for Node.js
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const axios = require("axios");

// Set the region
const REGION = "us-east-1";

// Create DynamoDB service object
const dbclient = new DynamoDBClient({ region: REGION });

exports.handler = async event => {
  const res = await axios.get("https://jsonplaceholder.typicode.com/todos/1");
  const promises = event.Records.map(record => {
    const body = JSON.parse(record.body);
    const size = body.data.length;
    const todo = {
      M: {
        id: {
          S: res.data.id.toString()
        },
        todo: {
          S: res.data.title
        }
      }
    };
    let todos = [];
    for (let counter = 0; counter < size; counter++) {
      todos.push(todo);
    }
    const params = {
      TableName: "jobs",
      Item: {
        jobId: { S: record.messageId },
        todos: { L: todos }
      }
    };
    const data = dbclient.send(new PutItemCommand(params));
    return data;
  });

  return Promise.all(promises);
};
