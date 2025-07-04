# Deployment of Sock Shop Demo Application by Myunggu Kang

This repository contains a collection of infrastructure as code (IaC) and deployment examples for the Sock Shop Demo application. It includes:

- **Terraform and Ansible code**: For provisioning AWS and Azure cloud infrastructure.
- **Jenkins Pipelines**: Examples for Continuous Integration (CI) and Continuous Delivery (CD).
- **Containerization**: Dockerfiles and Docker Compose configurations for the application services.
- **Kubernetes Deployments**: Manifests, Kustomize, and Helm charts for deploying to Kubernetes.
- **Traffic Management**: Istio configurations for advanced deployment strategies like blue-green, canary, and shadow deployments.

This project aims to provide a robust set of examples for testing and operating the Sock Shop Demo application across various deployment scenarios on cloud platforms.

Here's a detailed breakdown of the repository's structure and content:

### `aws/` and `azure/`
These directories contain the Infrastructure as Code (IaC) for provisioning cloud resources on AWS and Azure, respectively.
- **`terraform/`**: Includes Terraform configurations for setting up VPC, EC2 instances, EKS/AKS clusters, ECR/ACR, IAM roles, security groups, and other necessary cloud resources for deploying the Sock Shop application. Each module (`alb`, `ec2`, `eks`, `iam`, `security_groups`, `vpc`, `waf` for AWS; `acr`, `aks`, `app_gateway`, `bastion`, `jenkins`, `network`, `nsg` for Azure) is designed for modular and reusable infrastructure deployment.
- **`ansible/`**: Contains Ansible playbooks and roles for post-provisioning configurations, such as installing ArgoCD, Jenkins, and other necessary tools on the provisioned cloud instances.

### `deploy/`
This directory holds all the deployment-related artifacts for the Sock Shop Demo application.
- **`ci_cd_pipelines/`**:
    - **`docker-compose/`**: Jenkinsfile examples for CI/CD pipelines using Docker Compose, including specific examples for `sock-shop_front-end_ci_docker-compose.groovy` and `sock-shop_front-end_cd_docker-compose.groovy`.
    - **`manifest/`**: Jenkinsfile examples for CI/CD pipelines using Kubernetes manifests, such as `sock-shop_front-end_ci.groovy` and `sock-shop_front-end_cd.groovy`.
    - **`helm/` and `kustomize/`**: Placeholder directories for future Helm and Kustomize based CI/CD pipeline examples.
- **`docker-compose/`**: Contains `docker-compose.yml` files for orchestrating the Sock Shop microservices locally using Docker Compose.
- **`dockerfile/`**: Individual Dockerfiles for each microservice of the Sock Shop application (e.g., `Dockerfile-front-end`, `Dockerfile-carts`, `Dockerfile-catalogue`, etc.).
- **`kubernetes/`**:
    - **`manifest/`**: Kubernetes YAML manifests for deploying each Sock Shop microservice, including deployments, services, and horizontal pod autoscalers (HPAs).
    - **`helm/`**: Helm chart for deploying the Sock Shop application to Kubernetes, including `Chart.yaml`, `values.yaml`, and templates for deployments, services, and HPAs.
    - **`manifests-istio/`**: Istio-specific manifests like `gateway.yaml` and `virtual-services.yaml` for advanced traffic management.
    - **`release/`**: Consolidated Kubernetes manifests for release deployments.
- **`istio_deployment_strategies/`**: Examples of Istio configurations for various deployment strategies:
    - **`blue-green/`**: `sock-shop_front-end_v1.yaml` and `sock-shop_front-end_v2.yaml` for blue-green deployments.
    - **`canary/`**: `sock-shop_canary.yaml` for canary releases.
    - **`route-headers/`**: `sock-shop_route-headers.yaml` for routing based on HTTP headers.
    - **`shadow/`**: `sock-shop_shadow.yaml` for traffic shadowing.

### `demo_labs/`
This directory contains various lab exercises and simplified examples.
- **`lab1_docker_compose/`**: Includes a `docker-compose.yml`, `Dockerfile_front-end`, and a Jenkinsfile for a basic Docker Compose lab.
- **`lab2_manifest/`**: Contains Jenkinsfiles and a Kubernetes manifest for a basic Kubernetes manifest deployment lab.
- **`lab3_azure/`**: Examples for basic Terraform deployments on Azure.

This comprehensive structure allows for flexible deployment, testing, and operation of the Sock Shop Demo application across different environments and using various modern DevOps tools and practices.