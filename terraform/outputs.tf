output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "instance_id" {
  value = aws_instance.ec2_instance.id
}

output "private_ip" {
  value = aws_instance.ec2_instance.private_ip
}

output "subnet_id" {
  value = aws_instance.ec2_instance.subnet_id
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "key_pair_name" {
  value = aws_key_pair.ec2_key_pair.key_name
}

output "security_group_id" {
  value = aws_security_group.ec2_instance.id
}
