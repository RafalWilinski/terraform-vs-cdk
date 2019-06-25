resource "random_string" "password" {
  length = 16
  special = false
}

resource "aws_db_subnet_group" "default" {
  name       = "dbsubnetgroup"
  subnet_ids = [
    for subnet in aws_subnet.private:
    subnet.id
  ]

  depends_on = [aws_subnet.private]
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "10.6"
  instance_class         = "db.t2.micro"
  name                   = "terraformdb"
  username               = "terraformdb"
  password               = random_string.password.result
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Allow traffic from ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_security_group.ecs_tasks]
}
