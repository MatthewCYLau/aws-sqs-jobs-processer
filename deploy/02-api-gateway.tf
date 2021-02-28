resource "aws_api_gateway_rest_api" "app" {
  name        = "${var.app_name}-api"
  description = "AWS SQS Jobs API"
  body        = data.template_file.api_definition.rendered

}

data "template_file" "api_definition" {
  template = file("api/openapi.yaml")
  vars = {
    apig_invocation_uri               = "arn:aws:apigateway:${var.default_region}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.app_queue.name}"
    apig_role                         = aws_iam_role.apig_role.arn
    get_jobs_request_mapping_template = jsonencode(file("templates/getJobsRequestMappingTemplate.json"))
  }
}

resource "aws_api_gateway_deployment" "app" {
  depends_on = [
    aws_api_gateway_rest_api.app
  ]
  rest_api_id = aws_api_gateway_rest_api.app.id
  stage_name  = var.environment
}