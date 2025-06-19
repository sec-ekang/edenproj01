 # ------------------------------------------------------------------------------
# modules/ecr/outputs.tf
# ------------------------------------------------------------------------------
output "repository_urls" {
  description = "Map of repository names to their URLs."
  value       = { for name, repo in aws_ecr_repository.sock_shop_repos : name => repo.repository_url }
}