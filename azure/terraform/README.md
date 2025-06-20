# Azure Terraform Configuration

This directory contains the Terraform configuration for deploying resources to Azure. It is designed to support multiple environments (development, QA, staging, and production) with environment-specific resource sizing and security settings.

## Directory Structure

- `main.tf`: The main Terraform configuration file that orchestrates the deployment of Azure resources.
- `variables.tf`: Defines input variables for customizing the deployment.
- `locals.tf`: Contains environment-specific configurations, such as VM sizes, AKS node counts, and network security settings.
- `providers.tf`: Configures the Azure provider.
- `outputs.tf`: Defines output values from the Terraform deployment.
- `dev.tfvars.example`, `qa.tfvars.example`, `staging.tfvars.example`, `prod.tfvars.example`: Example variable definition files for different environments. Copy and rename these to `terraform.tfvars` for your specific environment.
- `modules/`: Contains reusable Terraform modules for individual Azure resources (e.g., AKS, Network, Bastion).

## Environments

This configuration supports the following environments, with tailored resource allocations:

- **Dev**: Minimal resources for development and testing. More permissive security settings.
- **QA**: Moderately sized resources for quality assurance testing. Stricter security.
- **Staging**: Production-like environment for final testing before release.
- **Prod**: High-availability and performance-oriented resources for live applications. Most restrictive security.

## Usage

1.  **Select an Environment**: Choose the appropriate `.tfvars.example` file for your target environment (e.g., `dev.tfvars.example`).
2.  **Configure Variables**: Copy the chosen `.tfvars.example` to `terraform.tfvars` and update the placeholder values (e.g., `a.b.c.d/32` for SSH CIDRs) with your actual desired configurations.
3.  **Initialize Terraform**: Run `terraform init` to initialize the working directory.
4.  **Plan the Deployment**: Run `terraform plan -var-file=terraform.tfvars` to preview the changes Terraform will make.
5.  **Apply the Deployment**: Run `terraform apply -var-file=terraform.tfvars` to apply the changes and deploy the resources to Azure. 