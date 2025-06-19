# Ansible for Jenkins Server Setup

This collection of Ansible files automates the provisioning of a Jenkins server on an Ubuntu system.

It installs:
- Java (OpenJDK 11)
- Jenkins
- Docker Engine
- Common build tools (`git`, `unzip`)
- Pipeline-specific CLIs:
  - `gitleaks`
  - `trivy`
  - `yq`
  - `kubectl`
  - `argocd-cli`
  - `sonar-scanner`

## Prerequisites
1.  An Ubuntu 20.04/22.04 server.
2.  Ansible installed on your local machine.
3.  SSH access to the server with a private key.

## How to Run
1.  Update the `inventory` file with your server's IP address and the path to your SSH private key.
2.  Navigate to the `ansible_jenkins_setup` directory.
3.  Run the playbook:
    ```bash
    ansible-playbook -i inventory playbook.yml
    ```
4.  After the playbook completes, browse to `http://<your_server_ip>:8080`.
5.  Retrieve the initial admin password from the server to complete the setup:
    ```bash
    ssh -i ~/.ssh/your_key.pem ubuntu@your_server_ip "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ```

---

### 3. The `jenkins-server` Role

This role contains all the logic for the setup.

#### `roles/jenkins-server/vars/main.yml`

This file defines the versions of the tools to be installed, making it easy to update them in the future.

```yaml
---
# vars file for jenkins-server
java_package: openjdk-11-jdk
jenkins_repo_key_url: "[https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key](https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key)"
jenkins_repo_url: "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] [https://pkg.jenkins.io/debian-stable](https://pkg.jenkins.io/debian-stable) binary/"

docker_repo_key_url: "[https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg)"
docker_repo_url: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) {{ ansible_lsb.codename }} stable"

# Versions for pipeline tools
gitleaks_version: "8.18.2"
trivy_version: "0.52.2"
yq_version: "v4.44.1"
kubectl_version: "1.29.3"
argocd_version: "v2.11.2"
sonar_scanner_version: "5.0.1.3006"

