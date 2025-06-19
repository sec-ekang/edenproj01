 # ------------------------------------------------------------------------------
# modules/ecr/main.tf
# ------------------------------------------------------------------------------
resource "aws_ecr_repository" "sock_shop_repos" {
  for_each = toset(var.repository_names)
  name     = each.key

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "Sock Shop"
  }
}