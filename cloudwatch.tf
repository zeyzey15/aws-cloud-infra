resource "aws_cloudwatch_metric_alarm" "jumphost_cpu_utilization" {
  alarm_name                = "jumphost-cpu-utilizationst"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [aws_sns_topic.jumphost.arn]   
}



 