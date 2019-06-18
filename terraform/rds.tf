resource "random_string" "password" {
  length = 16
  special = false
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.6"
  instance_class       = "db.t2.micro"
  name                 = "terraformdb"
  username             = "terraformdb"
  password             = "${random_string.password.result}"
  parameter_group_name = "default.postgres5.7"
}
