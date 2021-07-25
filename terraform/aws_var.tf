variable "ec2-key" {
  default = "ssh_key"
}

variable "ami" {
  default = "ami-0adfdaea54d40922b"
}

variable "instance_count" {
  default = "2"
}

variable "ssh_key" {
  type = string
  sensitive   = true
}

variable "aws_access_key" {
    type = string
    sensitive   = true
}
variable "aws_secret_key" {
    type = string
    sensitive   = true
}

# variable "aws_ssl_priv" {
#     type = string
#     sensitive   = true
# }
# variable "aws_ssl_cert" {
#     type = string
#     sensitive   = true
# }
# variable "aws_ssl_chain" {
#     type = string
#     sensitive   = true
# }