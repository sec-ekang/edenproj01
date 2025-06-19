 ################################################################################
# Root Module - outputs.tf
#
# This file defines the values that will be displayed to the user
# after `terraform apply` is complete. These are useful for accessing
# the created resources, like the ALB's DNS name or the Bastion's IP.
################################################################################

output "bastion_public_ip" {
  description = "The public IP address of the Bastion host."
  value       = module.ec2.bastion_public_ip
}

output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins server."
  value       = module.ec2.jenkins_public_ip
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for your EKS cluster's Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "configure_kubectl_command" {
  description = "Run this command to configure kubectl to connect to the EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_urls" {
  description = "A map of ECR repository names to their URLs."
  value       = module.ecr.repository_urls
}
