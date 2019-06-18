resource "aws_ecs_cluster" "main" {
  name = "${var.name}-Cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_task_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment":[{
      "name": "BUCKET_ARN",
      "value": "${aws_s3_bucket.assets-bucket.arn}"
    }, {
      "name": "DB_ENDPOINT",
      "value": "${aws_db_instance.default.endpoint}"
    }, {
      "name": "DB_USERNAME",
      "value": "terraformdb"
    }, {
      "name": "DB_PASSWORD",
      "value": "${random_string.password.result}"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.name}",
        "awslogs-region": "${var.region}",
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "app"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_alb_listener.app",
  ]
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ecs_tasks"
  description = "Allow traffic from the internet"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 49153
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
