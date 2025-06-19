# Ansible Automation for Sock Shop Environment

Here is a complete Ansible project to configure the EC2 instances and deploy ArgoCD. This project uses roles to create a modular and reusable structure.

### Ansible Project Structure

```
ansible/
├── inventory/
│   └── hosts.ini.example
├── playbook-bastion.yml
├── playbook-jenkins.yml
├── playbook-argocd.yml
└── roles/
    ├── argocd_install/
    │   └── tasks/
    │       └── main.yml
    ├── bastion_setup/
    │   └── tasks/
    │       └── main.yml
    ├── jenkins_install/
    │   └── tasks/
    │       └── main.yml
    └── tools_install/
        └── tasks/
            └── main.yml
```

### How to Use

1.  **Install Ansible**: Ensure Ansible is installed on your local machine or wherever you plan to run the playbooks from.
2.  **Prepare Inventory**:
    *   Copy `inventory/hosts.ini.example` to `inventory/hosts.ini`.
    *   Update `inventory/hosts.ini` with the public IP of your Bastion host and the private IP of your Jenkins server. The Terraform outputs will provide these values.
3.  **Configure SSH**: Ensure you can SSH into the Bastion host from your local machine, and from the Bastion to the Jenkins server. You may need to use SSH Agent Forwarding.

    ```bash
    # Add your private key to the agent
    ssh-add /path/to/your-key.pem

    # Run Ansible playbook with agent forwarding
    ansible-playbook -i inventory/hosts.ini --ssh-common-args='-o ForwardAgent=yes' playbook-jenkins.yml
    ```

4.  **Run Playbooks**: Execute the playbooks in order. The ArgoCD playbook should be run from the Bastion host where `kubectl` has been configured.

    ```bash
    # 1. Configure the Bastion Host
    ansible-playbook -i inventory/hosts.ini playbook-bastion.yml

    # 2. Configure the Jenkins Server (run from local machine with SSH agent forwarding)
    ansible-playbook -i inventory/hosts.ini --ssh-common-args='-o ForwardAgent=yes' playbook-jenkins.yml

    # 3. SSH into the Bastion Host to run the ArgoCD playbook
    ssh -A ec2-user@<BASTION_IP>
    # From inside the bastion, run:
    ansible-playbook -i inventory/hosts.ini playbook-argocd.yml
    ``` 