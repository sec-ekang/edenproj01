 # ------------------------------------------------------------------------------
# modules/security_groups/outputs.tf
# ------------------------------------------------------------------------------
output "bastion_sg_id" {
  description = "The ID of the Bastion security group."
  value       = aws_security_group.bastion.id
}

output "jenkins_sg_id" {
  description = "The ID of the Jenkins security group."
  value       = aws_security_group.jenkins.id
}

output "eks_node_sg_id" {
  description = "The ID of the EKS node security group."
  value       = aws_security_group.eks_nodes.id
}
