resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "${var.name}-ecs_execution_policy"
  path        = "/"
  description = "${var.name} ECS Task Execution Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-exec-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": [
                "ecs.amazonaws.com"
            ]
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-attachment" {
    role       = "${aws_iam_role.ecs_task_execution_role.name}"
    policy_arn = "${aws_iam_policy.ecs_execution_policy.arn}"
}
