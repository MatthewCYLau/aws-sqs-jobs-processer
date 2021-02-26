// Load the AWS SDK for Node.js
const AWS = require("aws-sdk");

// Set the region
AWS.config.update({ region: "us-east-1" });

// Create DynamoDB service object
const ddb = new AWS.DynamoDB({ apiVersion: "2012-08-10" });

exports.handler = async event => {
  ///some other stuff to set up the variables below

  const promises = event.Records.map(record => {
    const params = {
      TableName: "results",
      Item: {
        requestId: { S: record.messageId }
      }
    };

    return ddb
      .putItem(params)
      .promise()
      .then(item => {
        console.log(entity + " inserted");
        console.log(item);
        return item;
      })
      .catch(error => {
        console.log("ERROR: ");
        console.log(error);
        return error;
      });
  });

  return Promise.all(promises);
};
