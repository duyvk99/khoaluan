provider "aws" {
  profile    = "default"
  region     = "ap-southeast-1" //khu vuc singapore
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
