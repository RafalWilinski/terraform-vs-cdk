resource "aws_cloudwatch_log_group" "task_logs" {
  name = "${var.name}-logs"

  tags = {
    Application = var.name
  }
}

resource "aws_cloudwatch_log_stream" "task_stream" {
  name           = var.name
  log_group_name = aws_cloudwatch_log_group.task_logs.name
}
