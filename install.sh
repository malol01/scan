#!/bin/bash

# Install dos2unix if not already installed
sudo apt-get update
sudo apt-get install -y dos2unix

# Convert app.sh to Unix format
dos2unix app.sh

# Give execution permissions to app.sh
chmod +x app.sh

# Run app.sh
./app.sh
