resource "aws_s3_bucket" "assets-bucket" {
  bucket = "${var.name}-assets-bucket"
  acl    = "public-read"
}
