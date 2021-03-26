
# Terraform resource to deploy function as archive file

# data "archive_file" "process_queue_zip" {
#   type        = "zip"
#   source_file = "lambdas/processQueue.js"
#   output_path = "lambdas/processQueue.zip"
# }

resource "aws_lambda_function" "process_queue" {
  function_name = "ProcessQueueMessage"

  # Attributes to deploy function as archive file

  # filename         = data.archive_file.process_queue_zip.output_path
  # source_code_hash = data.archive_file.process_queue_zip.output_base64sha256
  # handler          = "processQueue.handler"
  # runtime          = "nodejs10.x"

  # Deploy Lambda function with dependencies
  # See https://docs.aws.amazon.com/lambda/latest/dg/nodejs-package.html#nodejs-package-dependencies
  # and https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws

  s3_bucket = "matlau-lambdas-bucket"
  s3_key    = "v1.0.0/processQueue.zip"
  handler   = "index.handler"
  runtime   = "nodejs10.x"

  role   = aws_iam_role.queue_processer_lambda.arn
  layers = [aws_lambda_layer_version.app.arn]
}

resource "aws_iam_role" "queue_processer_lambda" {
  name               = "${var.app_name}-process-queue-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "process_queue_attach" {
  role       = aws_iam_role.queue_processer_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_event_source_mapping" "map_sqs_queue" {
  event_source_arn = aws_sqs_queue.app_queue.arn
  function_name    = aws_lambda_function.process_queue.arn
}


resource "aws_iam_role_policy" "lambda_policy" {
  name = "prcoess-queue-lambda-policy"
  role = aws_iam_role.queue_processer_lambda.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SpecificTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": [
              "${aws_dynamodb_table.jobs.arn}*"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_layer_version" "app" {

  s3_bucket  = "matlau-lambdas-bucket"
  s3_key     = "v1.0.0/layer.zip"
  layer_name = "process-queue-layer"

  compatible_runtimes = ["nodejs10.x"]
}