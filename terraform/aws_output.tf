output "instance_aws_ip" {
  value = aws_instance.web-server.*.public_ip
  description = "Địa chỉ IP public của instance AWS"
}
