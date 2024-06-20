#!/bin/bash

# Update the package list and install required packages
sudo apt-get update
sudo apt-get install -y sshpass parallel pv

# Give execution permissions to the check_vps.sh script
chmod +x check_vps.sh

# Run the check_vps.sh script
./check_vps.sh
