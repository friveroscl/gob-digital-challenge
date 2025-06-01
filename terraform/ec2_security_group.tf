locals {
  friveros_ip_cidr = "${chomp(data.http.friveros_ip.response_body)}/32"
}


resource "aws_security_group" "ec2_instance" {
  name        = "${var.prefix}-instance"
  description = "${var.prefix}-instance security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access from friveros IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.friveros_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-instance"
  }
}


resource "aws_security_group_rule" "allow_ec2_instance_to_eks_api" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.ec2_instance.id
  description              = "Allow ${var.prefix}-instance to access ${module.eks.cluster_name} API"
}