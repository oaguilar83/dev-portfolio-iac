data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_public_cidr = "${chomp(data.http.local_ip.response_body)}/32"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = var.key_name
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Security group for web server"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    name = "web-server"
  }
}

resource "aws_route53_zone" "public-zone" {
  name = "oscaraguilardev.com"
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.public-zone.zone_id
  name    = "oscaraguilardev.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_server.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.public-zone.zone_id
  name    = "www.oscaraguilardev.com"
  type    = "A"

  alias {
    name                   = aws_route53_record.root_a_record.name
    zone_id                = aws_route53_record.root_a_record.zone_id
    evaluate_target_health = false
  }
}
