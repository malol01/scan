#!/bin/bash

# Read the IP and user:pass files
IP_FILE="vps_list.txt"
USER_PASS_FILE="user_pass.txt"

# Check if the files exist
if [[ ! -f $IP_FILE || ! -f $USER_PASS_FILE ]]; then
  echo "The files with IPs and authentication details must exist."
  exit 1
fi

# Read IPs and authentication details into arrays
IPS=($(cat $IP_FILE))
USER_PASS=($(cat $USER_PASS_FILE))

# Initialize counters
PASS_COUNT=0
FAIL_COUNT=0

# Function to check a VPS connection
check_vps() {
  local IP_PORT=$1
  local USER_PASS_PAIR=$2
  local USER=$(echo $USER_PASS_PAIR | cut -d':' -f1)
  local PASSWORD=$(echo $USER_PASS_PAIR | cut -d':' -f2)

  # Attempt to connect via SSH and run the `uname -a` command
  SSH_OUTPUT=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p $(echo $IP_PORT | cut -d':' -f2) $USER@$(echo $IP_PORT | cut -d':' -f1) "uname -a 2>/dev/null")

  # Check connection status
  if [ $? -eq 0 ]; then
    echo "Successful connection to $IP_PORT with $USER."
    echo "$IP_PORT $USER:$PASSWORD ($SSH_OUTPUT)" >> success.txt
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "Failed connection to $IP_PORT with $USER."
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi

  # Display current status
  echo -ne "Success: $PASS_COUNT, Fail: $FAIL_COUNT\r" >&2
}

export -f check_vps
export PASS_COUNT
export FAIL_COUNT

# Ask the user for the number of threads to use
read -p "Enter the number of threads to use: " THREADS

# Create a list of tasks for parallel
tasks=()
for IP in "${IPS[@]}"; do
  for USER_PASS_PAIR in "${USER_PASS[@]}"; do
    tasks+=("$IP $USER_PASS_PAIR")
  done
done

# Run tasks in parallel and show progress
echo "${#tasks[@]} tasks to complete"
printf "%s\n" "${tasks[@]}" | pv -l -s ${#tasks[@]} | parallel -j "$THREADS" --colsep ' ' check_vps

echo
