resource "aws_s3_bucket" "assets-bucket" {
  bucket = "${var.name}-AssetsBucket"
  acl    = "public"
}
