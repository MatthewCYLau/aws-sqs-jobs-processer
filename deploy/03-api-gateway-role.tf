resource "aws_iam_role" "apig_role" {
  name               = "${var.app_name}-apig-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "apig_policy" {
  name = "${var.app_name}-apig-policy"
  role = aws_iam_role.apig_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "sqs:SendMessage",
                "dynamodb:Scan",
                "dynamodb:Query"
            ],
            "Resource": [
                "${aws_sqs_queue.app_queue.arn}",
                "${aws_dynamodb_table.jobs.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apig_attach" {
  role       = aws_iam_role.apig_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}