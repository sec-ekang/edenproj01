 # ------------------------------------------------------------------------------
# modules/ec2/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "bastion_ami" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}

variable "jenkins_ami" {
  type = string
}

variable "jenkins_instance_type" {
  type = string
}

variable "key_name" {
  description = "EC2 Key Pair name."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host."
  type        = string
}

variable "jenkins_sg_id" {
  description = "Security group ID for the Jenkins server."
  type        = string
}

variable "bastion_iam_profile" {
    description = "IAM instance profile for bastion host"
    type = string
}

variable "jenkins_iam_profile" {
    description = "IAM instance profile for jenkins server"
    type = string
}