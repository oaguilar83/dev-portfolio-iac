data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = var.key_name

  tags = {
    name = "WebServer"
  }
}

resource "aws_route53_zone" "public-zone" {
  name = "oscaraguilardev.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.public-zone.zone_id
  name    = "www.oscaraguilardev.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web_server.public_ip]
}
