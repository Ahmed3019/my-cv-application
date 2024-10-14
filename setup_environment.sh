#!/bin/bash

# Ensure SSH key permissions are correct
chmod 600 ./nx-key.pem

# Run the Ansible playbook
ansible-playbook -i hosts setup_environment.yml
