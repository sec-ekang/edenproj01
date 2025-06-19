# ------------------------------------------------------------------------------
# modules/eks/main.tf
# ------------------------------------------------------------------------------
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids = [var.eks_node_sg_id]
  }

  depends_on = [
    var.eks_cluster_role_arn,
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodegroup"
  node_role_arn   = var.eks_nodegroup_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.nodegroup_instance_types

  scaling_config {
    desired_size = var.eks_node_scaling_desired_size
    max_size     = var.eks_node_scaling_max_size
    min_size     = var.eks_node_scaling_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    var.eks_nodegroup_role_arn
  ]

  tags = {
    Name = "${var.project_name}-eks-node"
  }
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}