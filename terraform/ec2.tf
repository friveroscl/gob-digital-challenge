locals {
  instance_type = "t3.micro"
  volume_size   = 20
  volume_type   = "gp3"
}


resource "random_integer" "index" {
  min = 0
  max = length(aws_subnet.public) - 1
}


resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  subnet_id                   = aws_subnet.public[random_integer.index.result].id
  vpc_security_group_ids      = [aws_security_group.ec2_instance.id]
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = local.volume_size
    volume_type = local.volume_type
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${var.prefix}-instance"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}