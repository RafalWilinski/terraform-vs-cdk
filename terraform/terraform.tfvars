variable "az_count" {
  default = "2"
}

variable "name" {
  default = "TerraformStack"
}

var "app_port" {
  default = "3000"
}

variable "fargate_cpu" {
  default = "512"
}

variable "fargate_memory" {
  default = "512"
}

variable "app_image" {}

var "app_count" {
  default = "1"
}