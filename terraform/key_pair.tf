resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.prefix}-instance"
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}


resource "aws_secretsmanager_secret" "ec2_secret" {
  name = "${var.prefix}-instance"
}


resource "aws_secretsmanager_secret_version" "ec2_secret_version" {
  secret_id = aws_secretsmanager_secret.ec2_secret.id

  secret_string = jsonencode({
    private_key = tls_private_key.ec2_private_key.private_key_pem
    public_key  = tls_private_key.ec2_private_key.public_key_openssh
  })
}