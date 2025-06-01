locals {
  cluster_name    = "${var.prefix}-eks"
  cluster_version = "1.32"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.35"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  create_cloudwatch_log_group            = true
  cluster_enabled_log_types              = ["api", "audit", "authenticator"]
  cloudwatch_log_group_retention_in_days = 90

  # cluster_addons = {
  #   coredns                = {}    # in eks auto mode
  #   kube-proxy             = {}    # this add-ons are
  #   vpc-cni                = {}    # already included
  #   eks-pod-identity-agent = {}    # ...
  # }

  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  create_iam_role          = true
  iam_role_name            = "${local.cluster_name}-auto-cluster-role"
  iam_role_use_name_prefix = false

  create_node_iam_role          = true
  node_iam_role_name            = "${local.cluster_name}-auto-node-role"
  node_iam_role_use_name_prefix = false

  create_cluster_security_group          = true # this is not primary sg
  cluster_security_group_name            = "${local.cluster_name}-cluster-sg"
  cluster_security_group_use_name_prefix = false

  create_node_security_group          = true
  node_security_group_name            = "${local.cluster_name}-node-sg"
  node_security_group_use_name_prefix = false

  #  cluster_security_group_additional_rules = {
  #    vpn = {
  #      cidr_blocks = [local.friveros_ip_cidr]
  #      description = "Allow traffic from friveros host to Kubernetes API"
  #      from_port   = 443
  #      to_port     = 443
  #      protocol    = "tcp"
  #      type        = "ingress"
  #    }
  #  }

  cluster_encryption_policy_name            = "${local.cluster_name}-encryption-policy"
  cluster_encryption_policy_use_name_prefix = false

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"

  cluster_upgrade_policy = {
    "support_type" = "EXTENDED"
  }

  cluster_compute_config = {
    enabled = true
  }

  tags = {
    Name = "${var.prefix}-eks"
  }
}


resource "aws_eks_access_entry" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
}


resource "aws_eks_access_policy_association" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn

  access_scope {
    type = "cluster"
  }
}