resource "aws_eip" "aws-eip" {
  count = length(aws_instance.web-server)
  vpc = true
  instance = element(aws_instance.web-server.*.id, count.index)

  tags = {
    Name = "aws-eip-${count.index + 1}"
  }
}

resource "aws_lb_target_group" "target-group-vps" {
  health_check {
    interval = 10
    path     = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = 301
  }

  name = "target-group-vps"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.hai-vpc.id
}

resource "aws_lb" "load-balancer" {
  name = "aws-loadbalancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.allow_ports.id
  ] 

  subnet_mapping {
    subnet_id            = aws_subnet.private-subnet.id
  }

  subnet_mapping {
    subnet_id            = aws_subnet.public-subnet.id
  }

  ip_address_type = "ipv4"
  tags = {
    Name = "aws-loadbalancer" 
  }
}

resource "aws_lb_listener" "lb-listener" {
    load_balancer_arn = aws_lb.load-balancer.arn 
        port = 80 # 443
        protocol = "HTTP" # "HTTPS"
        default_action {
            target_group_arn =  aws_lb_target_group.target-group-vps.arn
            type = "forward"
        }

  depends_on = [
    aws_lb.load-balancer,
    aws_lb_target_group.target-group-vps,
  ]
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  count = var.instance_count
  target_group_arn = aws_lb_target_group.target-group-vps.arn 
  target_id           = aws_instance.web-server[count.index].id
}
