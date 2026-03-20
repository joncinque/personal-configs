#!/usr/bin/env bash

# Timeout duration in seconds (15 minutes)
timeout_duration=$((15 * 60))
start_time=$(date +%s)

# Check every 10 seconds if port 8899 is active
while true; do
    # Check if the current time exceeds the timeout duration
    current_time=$(date +%s)
    if ((current_time - start_time > timeout_duration)); then
        echo "Timeout reached. Port 8899 is not active."
        exit 1
    fi

    # Try to connect to port 8899
    if nc -z localhost 8899; then
        echo "Port 8899 has become active."
        exit 0
    else
        echo "Waiting for port 8899 to become active..."
    fi

    # Sleep for 10 seconds before retrying
    sleep 10
done
