#!/bin/bash
sudo apt update && sudo apt dist-upgrade -y
sudo apt install ansible -y
ansible-playbook playbook.yml
