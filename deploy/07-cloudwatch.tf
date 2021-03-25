resource "aws_cloudwatch_metric_alarm" "process_queue" {
  alarm_name          = "process-queue-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Lambda error metrics"
  dimensions = {
    FunctionName = aws_lambda_function.process_queue.function_name
  }
  alarm_actions = [aws_sns_topic.app.arn]
}