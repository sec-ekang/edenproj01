# Azure Jenkins Infrastructure with Terraform

This README outlines the steps to deploy a Jenkins instance on Azure using Terraform, including the necessary CLI installations, troubleshooting common issues, and resource cleanup.

## 1. Prerequisites

*   A Linux environment (Ubuntu/Debian)
*   Azure subscription

## 2. Install Terraform

First, install Terraform on your Linux system:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
```

## 3. Install Azure CLI

Next, install the Azure CLI to interact with your Azure subscription:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## 4. Authenticate Azure CLI

Log in to your Azure account using the Azure CLI:

```bash
az login
```

Follow the instructions in your web browser to complete the authentication.

## 5. Generate SSH Key

Generate an SSH key pair required for the Jenkins VM:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

## 6. Initialize Terraform Project

Navigate to the `terraform/jenkins` directory and initialize the Terraform project to download necessary providers:

```bash
cd terraform/jenkins
terraform init
```

## 7. Review and Apply Terraform Configuration

Before applying, review the plan to see what resources will be created.

```bash
terraform plan
```

### Troubleshooting: `network_security_group_id` error

If you encounter an error related to `network_security_group_id` not being supported directly on `azurerm_network_interface`, it means you need to use a separate resource for the association. Ensure your `main.tf` file uses `azurerm_network_interface_security_group_association` like this:

```terraform
// ... existing code ...

resource "azurerm_network_interface" "nic" {
  name                = "jenkins-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
// ... existing code ...
}
```

### Troubleshooting: Jenkins Java Version

If Jenkins fails to start due to an outdated Java version (e.g., Java 11 installed, but Java 17 required), update the `custom_data` in your `main.tf` to install the correct OpenJDK version:

```terraform
// ... existing code ...
  custom_data = base64encode(<<EOT
#!/bin/bash
sudo apt update -y
sudo apt install -y openjdk-17-jdk wget
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
EOT
  )
}
```

After making any necessary corrections to `main.tf`, apply the configuration:

```bash
terraform apply --auto-approve
```

## 8. Verify Jenkins Access

After successful deployment, Jenkins should be accessible on port 8080 of the VM's public IP address. You can verify this using `curl`:

```bash
curl -v <YOUR_PUBLIC_IP>:8080
```

Replace `<YOUR_PUBLIC_IP>` with the public IP address obtained from the `terraform apply` output.

## 9. Destroy Resources

Once you are done, destroy all created Azure resources to avoid incurring unnecessary costs:

```bash
cd terraform/jenkins
terraform destroy --auto-approve
``` 