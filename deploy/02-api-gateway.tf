resource "aws_api_gateway_rest_api" "app" {
  name        = "${var.app_name}-api"
  description = "AWS SQS Jobs API"
  body = templatefile("api/openapi.yaml", {
    apig_invocation_uri                     = "arn:aws:apigateway:${var.default_region}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.app_queue.name}"
    apig_role                               = aws_iam_role.apig_role.arn
    get_jobs_request_mapping_template       = jsonencode(file("templates/getJobsRequestMappingTemplate.json"))
    get_jobs_response_mapping_template      = jsonencode(file("templates/getJobsResponseMappingTemplate.json"))
    get_job_by_id_request_mapping_template  = jsonencode(file("templates/getJobByIdRequestMappingTemplate.json"))
    get_job_by_id_response_mapping_template = jsonencode(file("templates/getJobByIdResponseMappingTemplate.json"))
    post_jobs_response_mapping_template     = jsonencode(file("templates/postJobsResponseMappingTemplate.json"))
  })

}

resource "aws_api_gateway_deployment" "app" {
  depends_on = [
    aws_api_gateway_rest_api.app
  ]
  rest_api_id = aws_api_gateway_rest_api.app.id
  stage_name  = var.environment
}

resource "aws_api_gateway_usage_plan" "daily_limit" {
  name        = "${var.app_name}-daily-limit"
  description = "${var.app_name} daily limit"

  api_stages {
    api_id = aws_api_gateway_rest_api.app.id
    stage  = var.environment
  }

  quota_settings {
    limit  = 10
    offset = 0
    period = "DAY"
  }
}