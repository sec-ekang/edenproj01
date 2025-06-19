 # ------------------------------------------------------------------------------
# modules/ec2/main.tf
# ------------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.bastion_sg_id]
  iam_instance_profile   = var.bastion_iam_profile

  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}

resource "aws_instance" "jenkins" {
  ami           = var.jenkins_ami
  instance_type = var.jenkins_instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_ids[1]
  vpc_security_group_ids = [var.jenkins_sg_id]
  iam_instance_profile   = var.jenkins_iam_profile

  tags = {
    Name = "${var.project_name}-jenkins-server"
  }
}