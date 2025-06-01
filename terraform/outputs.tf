output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_public_subnets" {
  value = aws_subnet.public[*].id
}

output "vpc_private_subnets" {
  value = aws_subnet.private[*].id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "ec2_instance_id" {
  value = aws_instance.ec2_instance.id
}

output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.ec2_instance.private_ip
}

output "ec2_subnet_id" {
  value = aws_instance.ec2_instance.subnet_id
}

output "ec2_ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_key_pair_name" {
  value = aws_key_pair.ec2_key_pair.key_name
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_instance.id
}
