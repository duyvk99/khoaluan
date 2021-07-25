resource "aws_vpc" "hai-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "hai-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hai-vpc.id
  tags = {
    Name = "terraform-IGW"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.hai-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet-10.0.1.0/24"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.hai-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true  
  tags = {
    Name = "public-subnet-10.0.2.0/24"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.hai-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "private-subnet-10.0.1.0/24"
  }
}

resource "aws_route_table_association" "route_table"{
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "allow_ports" {
  name        = "allow_ports"
  description = "Allow all inbound ssh traffic "
  vpc_id = aws_vpc.hai-vpc.id
    
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }
  tags = {
    Name = "allow_ports"
  }
}

resource "aws_security_group" "lb-ports" {
  name        = "loadbalancer-ports"
  description = "Allow http,https traffic "
  vpc_id = aws_vpc.hai-vpc.id
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks     = ["::/0"]
  }

  tags = {
    Name = "loadbalancer_ports"
  }
}