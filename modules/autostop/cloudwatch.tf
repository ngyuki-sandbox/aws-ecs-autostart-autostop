data "aws_lb_target_group" "this" {
  arn = var.target_group_arn
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.name
  alarm_actions       = [aws_sns_topic.this.arn]
  namespace           = "AWS/ApplicationELB"
  metric_name         = "RequestCountPerTarget"
  statistic           = "Sum"
  treat_missing_data  = "missing"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  dimensions = {
    TargetGroup = data.aws_lb_target_group.this.arn_suffix
  }
}
