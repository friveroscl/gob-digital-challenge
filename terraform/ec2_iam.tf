resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.prefix}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "ec2_instance_policy" {
  name        = "${var.prefix}-instance-policy"
  description = "IAM policy for ${var.prefix}-instance"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = "*" # Or "arn:aws:eks:<region>:<account_id>:cluster/<cluster_name>"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_instance_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_instance_policy.arn
}


# mac:
# brew install --cask session-manager-plugin
# linux:
# curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
# sudo dpkg -i session-manager-plugin.deb
# then:
# aws ssm start-session --target <INSTANCE_ID>
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.prefix}-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}


resource "aws_eks_access_entry" "ec2_eks_access_entry" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ec2_instance_role.arn
  type          = "STANDARD"
}


resource "aws_eks_access_policy_association" "ec2_eks_access_policy_association" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.ec2_instance_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}