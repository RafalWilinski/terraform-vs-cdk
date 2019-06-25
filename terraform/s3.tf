resource "aws_s3_bucket" "assets-bucket" {
  bucket = "${var.name}-assets-s3-bucket"
  acl    = "public-read"
}
