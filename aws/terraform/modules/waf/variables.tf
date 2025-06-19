 # ------------------------------------------------------------------------------
# modules/waf/variables.tf
# ------------------------------------------------------------------------------
variable "project_name" {
  type = string
}

variable "alb_arn" {
  description = "The ARN of the Application Load Balancer to associate with WAF."
  type        = string
}