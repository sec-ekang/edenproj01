 ################################################################################
# Root Module - variables.tf
#
# This file declares all the input variables that users can provide
# to customize the deployment (e.g., region, VPC CIDR block, instance types).
################################################################################

variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
  default     = "sock-shop"
}

variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "A list of Availability Zones to use for the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# --- VPC Variables ---
variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# --- Environment-Specific Variables ---
variable "environment" {
  description = "The deployment environment (e.g., dev, qa, staging, prod)."
  type        = string
}

variable "qa_bastion_ssh_cidrs" {
  description = "CIDR block for Bastion host SSH access in the QA environment."
  type        = list(string)
  default     = []
}

variable "staging_prod_bastion_ssh_cidrs" {
  description = "CIDR block for Bastion host SSH access in Staging and Prod."
  type        = list(string)
  default     = []
}

# --- EC2 Variables ---
variable "key_name" {
  description = "The name of the EC2 key pair to use for the instances."
  type        = string
  # Note: You need to create this key pair in the AWS console first.
}

variable "bastion_ami" {
  description = "The AMI ID for the Bastion host."
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI in us-east-1
}

variable "jenkins_ami" {
  description = "The AMI ID for the Jenkins server."
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI in us-east-1
}

# --- EKS Variables ---
variable "eks_cluster_name" {
  description = "The name for the EKS cluster."
  type        = string
  default     = "sock-shop-cluster"
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.28"
}

# --- ECR Variables ---
variable "ecr_repository_names" {
  description = "A list of names for the ECR repositories."
  type        = list(string)
  default = [
    "front-end", "carts", "catalogue", "orders", "payment",
    "shipping", "queue-master", "user", "rabbitmq", "catalogue-db", "user-db"
  ]
}

# --- ALB Variables ---
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB to use for HTTPS."
  type        = string
  # Note: You must request or import a certificate in ACM for your domain first.
}
