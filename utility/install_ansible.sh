#!/usr/bin/env bash

# Install Ansible
sudo apt -y update
sudo apt install -y software-properties-common python3-pip python3-boto3 
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt -y update
sudo apt install -y ansible ansible-lint python3-argcomplete 

# Install CLI completion
sudo activate-global-python-argcomplete3

# Install VSCode extension
code --install-extension redhat.ansible