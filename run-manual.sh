#!/usr/bin/env bash

# This script gets some input and then runs the Ansible playbooks


# Exit immediately on any non-zero status return
set -e


# This function "run_playbook" invokes the playbook file specified by the first argument
# to the function, or `configure_server.yml` if none is provided. It uses the second
# argument to the function as the inventory or `inventories/inventory` if none
# is provided. It uses the third argument to determine if it should connect via ssh 
# using a specific path to a key.
function run_playbook() {
  local PLAYBOOK=$1
  if [ -z "${PLAYBOOK}" ]; then
    PLAYBOOK=configure_server.yml
  fi
  local INVENTORY=$2
  if [ -z "${INVENTORY}" ]; then
    INVENTORY=../inventories/inventory
  fi
  # Run the specified playbook with the specified Ansible inventory
  local SSHKEY=$3
  if [ "${SSHKEY}" == "none" ]; then
    echo; echo; ansible-playbook \
      -i $INVENTORY \
      "$PLAYBOOK"
  else
    echo; echo; ansible-playbook \
      -i $INVENTORY \
      "$PLAYBOOK" \
      --private-key ${SSHKEY}   
  fi
}


# This function "existing_server" asks some questions about the existing server and then 
# invokes the configure_server.yml playbook by calling the "run_playbook" function above
function existing_server() {
  read -r -p "What is the IP of the existing server?: " SERVER_IP

  read -r -p "What is the ssh username we should use on the existing server?: " SSH_USER

  read -r -p "If the user that is executing this script has a valid private key configured in ~/.ssh for the above-specified user on the target server, then we should be good to go. Otherwise, you'll need to specify a location of the private key that should be used to connect. Do you need to specify a location for the private key? (y/n): " SSH_KEY_LOCATION_REQUIRED   
      if [ "${SSH_KEY_LOCATION_REQUIRED}" == "y" ]; then
        read -r -p "What is the full path to the private key we should use going forward for the ssh user on the existing server: " SSH_KEY
      else
        SSH_KEY="none"
      fi
  
  # Create an inventory file string on the fly
  read -r -d '' TEMPL << EOF || true
[localhost]
localhost ansible_connection=local ansible_python_interpreter=python
[target-hosts]
$SERVER_IP ansible_user=$SSH_USER
EOF

  # Test SSH connection to the server 

  if [ "${SSH_KEY_LOCATION_REQUIRED}" == "y" ]; then
    ssh -i $SSH_KEY "$SSH_USER@$SERVER_IP" -o BatchMode=yes -t true
  fi
  if [ "${SSH_KEY_LOCATION_REQUIRED}" == "n" ]; then
    ssh "$SSH_USER@$SERVER_IP" -o BatchMode=yes -t true
  fi


  # Create the inventory file 
  if [ -d "../inventories" ]; then
    echo "$TEMPL" > ../inventories/inventory-existing
    INVENTORY_FILE="../inventories/inventory-existing"
  else
    mkdir inventories
    echo "$TEMPL" > inventories/inventory-existing
    INVENTORY_FILE="inventories/inventory-existing"
  fi
  
  # Invoke the default playbook on the existing server inventory
  run_playbook configure_server.yml $INVENTORY_FILE $SSH_KEY
}

existing_server;