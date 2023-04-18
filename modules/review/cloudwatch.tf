resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.name
  alarm_description   = aws_ssm_parameter.main.name
  alarm_actions       = [aws_sns_topic.this.arn]
  namespace           = "AWS/ApplicationELB"
  metric_name         = "RequestCountPerTarget"
  statistic           = "Sum"
  treat_missing_data  = "missing"
  period              = 60
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  dimensions = {
    TargetGroup = aws_lb_target_group.main.arn_suffix
  }
}
