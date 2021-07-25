resource "aws_instance" "web-server" {
  count = var.instance_count

  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = var.ec2-key
  vpc_security_group_ids = [
    aws_security_group.allow_ports.id,
    ] 

  associate_public_ip_address = "true"
  subnet_id = aws_subnet.public-subnet.id

  depends_on = [
    aws_security_group.allow_ports,
  ]

  provisioner "file" {
    source      = "./script/install_docker.sh"
    destination = "~/install_docker.sh"    // ~/ = /home/centos 
    on_failure = continue
    
    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "echo 'IP Address: ${self.private_ip} install docker'",
      "bash install_docker.sh",
      "rm -rf install_docker.sh",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/khoaluan/docker",
      "docker-compose up -d --build",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file(var.ssh_key)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "terraform-web-server${count.index}"
  }
  
}
