 ################################################################################
# Root Module - main.tf
#
# This file is the main entry point for the Terraform deployment.
# It defines which modules to use and how they are connected.
# Outputs from one module (like VPC ID) are used as inputs for others.
################################################################################

# --- Networking ---
module "vpc" {
  source = "./modules/vpc"

  region               = var.region
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# --- Security ---
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  bastion_ssh_cidr = var.bastion_ssh_cidr
}

module "iam" {
  source = "./modules/iam"

  project_name          = var.project_name
  aws_account_id        = data.aws_caller_identity.current.account_id
  oidc_provider_url     = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn     = module.eks.oidc_provider_arn
}

# --- ECR (Container Images) ---
module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repository_names
}

# --- EKS (Kubernetes Cluster) ---
module "eks" {
  source = "./modules/eks"

  project_name          = var.project_name
  cluster_name          = var.eks_cluster_name
  cluster_version       = var.eks_cluster_version
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_cluster_role_arn  = module.iam.eks_cluster_role_arn
  eks_nodegroup_role_arn= module.iam.eks_nodegroup_role_arn
  nodegroup_instance_types = var.eks_nodegroup_instance_types
  eks_node_sg_id        = module.security_groups.eks_node_sg_id
}

# --- EC2 Instances ---
module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  bastion_ami         = var.bastion_ami
  bastion_instance_type = var.bastion_instance_type
  jenkins_ami         = var.jenkins_ami
  jenkins_instance_type = var.jenkins_instance_type
  key_name            = var.key_name
  public_subnet_ids   = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]] # Deploy in first two public subnets
  bastion_sg_id       = module.security_groups.bastion_sg_id
  jenkins_sg_id       = module.security_groups.jenkins_sg_id
  bastion_iam_profile = module.iam.bastion_instance_profile_name
  jenkins_iam_profile = module.iam.jenkins_instance_profile_name
}

# --- Load Balancing and WAF ---
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  acm_certificate_arn = var.acm_certificate_arn
  eks_node_sg_id     = module.security_groups.eks_node_sg_id
}

module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  alb_arn      = module.alb.alb_arn
}
