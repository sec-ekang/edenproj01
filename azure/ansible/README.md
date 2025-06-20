# Ansible Automation for Azure Sock Shop Environment

This Ansible project configures the necessary VMs and deploys ArgoCD for the Sock Shop application on Azure.

### How to Use

1.  **Prerequisites**:
    *   Ansible installed on your local machine.
    *   An Azure environment provisioned with a Bastion host, a Jenkins VM, and an AKS cluster (presumably via the Terraform code in `azure/terraform`).
    *   The Bastion VM must have a Managed Identity assigned with the `Azure Kubernetes Service Cluster User Role` on your AKS cluster to allow `kubectl` configuration.

2.  **Prepare Inventory**:
    *   Copy `inventory/hosts.ini.example` to `inventory/hosts.ini`.
    *   Update `inventory/hosts.ini` with the public IP of your Bastion host and the private IP of your Jenkins server.
    *   Update the path to your SSH private key.

3.  **Run Playbooks**: Execute the playbooks in order.

    ```bash
    # 1. Configure the Bastion Host
    # This playbook installs the Azure CLI and kubectl, then configures kubectl access to AKS.
    ansible-playbook -i inventory/hosts.ini playbook-bastion.yml

    # 2. Configure the Jenkins Server
    # This playbook installs Jenkins, Docker, and other tools on the Jenkins VM.
    ansible-playbook -i inventory/hosts.ini playbook-jenkins.yml

    # 3. Deploy ArgoCD
    # This playbook runs locally on the bastion to deploy ArgoCD to the AKS cluster.
    # You can run this from your local machine if you configure the inventory to connect to the bastion.
    ansible-playbook -i inventory/hosts.ini playbook-argocd.yml
    ``` 