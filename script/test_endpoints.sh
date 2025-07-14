#!/bin/env bash

# This script is used to test the endpoints of the application.
set -e      # Exit immediately if a command exits with a non-zero status.
set -u      # Treat unset variables as an error.
set -o pipefail  # Prevent errors in a pipeline from being masked.

# Define the base URL for the API
BASE_URL=$1

# Define the endpoints to test
ENDPOINTS=(
    "${BASE_URL}"
    "${BASE_URL}/api/v1.0/weather?location=london"
    "${BASE_URL}/api/v1.0/temperature?location=birmingham"
    "${BASE_URL}/api/v1.0/wind?location=manchester"
    "${BASE_URL}/api/v1.0/humidity?location=reading"
)

for endpoint in ${ENDPOINTS[@]}; do
    HTTP_Code=$(curl -so /dev/null -w "%{http_code}" "$endpoint")
    if [ "$HTTP_Code" -eq 200 ]; then
        echo "Success: $endpoint returned HTTP status $HTTP_Code"
    else
        echo "Error: $endpoint returned HTTP status $HTTP_Code"
        exit 1
    fi
done