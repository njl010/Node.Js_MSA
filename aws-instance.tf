provider "aws" {
  region = "ap-south-1"
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "MY-PROJECT-SG"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "allow-ssh-http"
  }
}

resource "aws_instance" "web_server" {
  for_each = toset(["one", "two", "three"])

  ami           = "ami-02b8269d5e85954ef"
  instance_type = "t3.micro"
  key_name      = "miracle-key"

  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "server-${each.key}"
  }
}

resource "aws_eip" "elastic_for_one" {
  for_each = { for k, v in aws_instance.web_server : k => v if k == "one" }

  instance = each.value.id

  tags = {
    Name = "elastic-ip-for-${each.key}"
  }
}

output "instance_public_ips" {
  value = { for k, v in aws_instance.web_server : k => v.public_ip }
}

output "elastic_ip" {
  value = { for k, v in aws_eip.elastic_for_one : k => v.public_ip }
}

output "security_group_id" {
  value = aws_security_group.allow_ssh_http.id
}
