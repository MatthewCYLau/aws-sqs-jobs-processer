// Load the AWS SDK for Node.js
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
// const axios = require("axios");

// Set the region
const REGION = "us-east-1";

// Create DynamoDB service object
const dbclient = new DynamoDBClient({ region: REGION });

const uuidv4 = () =>
  "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
    var r = (Math.random() * 16) | 0,
      v = c == "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });

exports.handler = async event => {
  // const res = await axios.get("https://jsonplaceholder.typicode.com/todos/1");
  const promises = event.Records.map(record => {
    // const messageAttribute = record.messageAttributes.foo.stringValue;
    const body = JSON.parse(record.body);
    const size = body.data.length;
    const createTodo = todo => {
      return {
        M: {
          id: {
            S: uuidv4()
          },
          todo: {
            S: todo
          }
        }
      };
    };
    let todos = [];
    for (let counter = 0; counter < size; counter++) {
      todos.push(createTodo(body.data[counter]));
    }
    const params = {
      TableName: "jobs",
      Item: {
        jobId: { S: record.messageId },
        todos: { L: todos },
        created: { S: new Date().toISOString() },
        userId: { S: (Math.floor(Math.random() * 100) + 1).toString() }
      }
    };
    const data = dbclient.send(new PutItemCommand(params));
    return data;
  });

  return Promise.all(promises);
};
