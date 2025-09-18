#!/bin/bash

# GCP instance details
INSTANCE_NAME="wanderlust-mega-project"
ZONE="us-central1-f"

# Retrieve the public IP address of the specified GCP instance
ipv4_address=$(gcloud compute instances describe $INSTANCE_NAME \
  --zone=$ZONE \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Path to the .env file
file_to_find="../frontend/.env.docker"

# Check the current VITE_API_PATH in the .env file
current_url=$(cat $file_to_find)

# Update the .env file if the IP address has changed
if [[ "$current_url" != "VITE_API_PATH=\"http://${ipv4_address}:31100\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|VITE_API_PATH.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|g" $file_to_find
        echo "Updated VITE_API_PATH to http://${ipv4_address}:31100"
    else
        echo "ERROR: File not found at $file_to_find"
    fi
else
    echo "No change in IP. VITE_API_PATH already set correctly."
fi
