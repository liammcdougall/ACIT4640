#!/user/bin/env bash

# Install Terraform under Debian based Linux distributions like Ubuntu
# Update packagages
sudo apt-get -y update 

# Install gnupg and software-properties-common
sudo apt-get install -y gnupg software-properties-common

# Get and store HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp Keyring to shared keyrings
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

# Add HashiCorp repository to apt sources list
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package list incuding HashiCorp packages
sudo apt update

#Install Terraform
sudo apt-get -y install terraform

# Install CLI completion
terraform -install-autocomplete

# Install VSCode extension
code --install-extension hashicorp.terraform