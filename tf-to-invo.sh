#!/bin/bash

#PublicIPs=$(terraform output -json instance_public_ips) 

#echo "all:" >> inventory.yml
#echo "  hosts:" >> inventory.yml

Master_node=$(terraform output -json instance_public_ips | jq -r '.one')
Worker1_node=$(terraform output -json instance_public_ips | jq -r '.two')
Worker2_node=$(terraform output -json instance_public_ips | jq -r '.three')
SSH_USER=$(terraform output -raw ssh_user)
cat > ./ansible/inventory.yml << EOF
all: 
  hosts:
    master:
      ansible_host: $Master_node
      ansible_user: $SSH_USER

    worker1:
      ansible_host: $Worker1_node
      ansible_user: $SSH_USER

    worker2:
      ansible_host: $Worker2_node
      ansible_user: $SSH_USER

EOF