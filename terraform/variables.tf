variable "az_count" {
  default = "2"
}

variable "name" {
  default = "terraform-stack"
}

variable "app_port" {
  default = "3000"
}

variable "fargate_cpu" {
  default = "256"
}

variable "fargate_memory" {
  default = "512"
}

variable "app_image" {
  default = "terraform-vs-cdk:latest"
}

variable "app_count" {
  default = "1"
}
