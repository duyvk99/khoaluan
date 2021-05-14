resource "aws_instance" "web-server" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = var.ec2-key
  vpc_security_group_ids = [aws_security_group.allow_all_ssh_http_https.id] 
  

  // tạo file inventory với thông tin máy ảo sẵn sàng
  provisioner "local-exec" {
    command = "echo [webserver] > ../ansible-main/AWS_hosts"
    on_failure = continue
  }

  provisioner "local-exec" {
    command = "echo server1 ansible_host=${aws_instance.web-server.public_ip} ansible_user=centos ansible_ssh_private_key_file=../AWS/ssh_key.pem >> ../ansible-main/AWS_hosts"
    on_failure = continue
  }

  // Tao file AWS_easy_access.txt
  provisioner "local-exec" {
    command = "echo '# Lenh ssh vao Instance' >  AWS_easy_access.txt"
    on_failure = continue
  }
  
  provisioner "local-exec" {
    command = "echo '# ssh -i ssh_key.pem centos@${aws_instance.web-server.public_ip} ' >> AWS_easy_access.txt"
    on_failure = continue
  }

  provisioner "file" {
    source      = "./script/install_docker.sh"
    destination = "~/install_docker.sh"    // ~/ = /home/centos 
    on_failure = continue
    
    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.ssh_key)
      host        = aws_instance.web-server.public_ip
    }
  }

  // Chay script cai dat docker + docker-compose 
  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "echo 'IP Address: ${aws_instance.web-server.private_ip} install docker'",
      "bash install_docker.sh",
      "rm -rf install_docker.sh",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.ssh_key)
      host        = aws_instance.web-server.public_ip
    }
  }

  # // Copy tất cả file trong thư mục docker đến /home/centos/docker
  # provisioner "file" {
  #   source      = "../docker"
  #   destination = "~/"    // ~/ = /home/centos 
  #   on_failure = continue

  #   connection {
  #     type        = "ssh"
  #     user        = "centos"
  #     private_key = file(var.ssh_key)
  #     host        = aws_instance.web-server.public_ip
  #   }
  # }
 
  tags = {
    Name = "terraform-web-server"
  }
  
}