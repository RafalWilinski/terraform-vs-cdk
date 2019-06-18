resource "aws_cloudwatch_log_group" "task_logs" {
  name = "${var.name}-logs"

  tags = {
    Application = "${var.name}"
  }
}
