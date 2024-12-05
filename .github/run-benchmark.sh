#!/bin/bash

# To make file fail on failures
set -e

# Function to check if JMeter is installed
check_jmeter_installed() {
  if ! command -v jmeter &> /dev/null
  then
      echo "JMeter could not be found, installing JMeter..."
      sudo apt-get update
      sudo apt-get install -y jmeter
  else
      echo "JMeter is already installed."
  fi
}

# Ensure JMeter is installed
check_jmeter_installed

# Print out all running teastore containers
docker ps --filter "name=teastore"



# Ensure Docker containers are running
docker ps | grep teastore
if [ $? -ne 0 ]; then
  echo "TeaStore containers are not running. Ensure the services are up before running the benchmark."
  exit 1
fi

# Define variables
JMETER_TEST_PLAN="./performance_tests/teastore_load_test.jmx"  # Path to your .jmx test plan
RESULTS_DIR="./performance_tests/results"                      # Directory to save results
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl" # Timestamped results file
DOCKER_NETWORK="teastore_default"                              # Docker network name (verify with `docker network ls`)

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

echo "Running JMeter load test on TeaStore services..."

# Run JMeter in non-GUI mode targeting the running Docker containers
jmeter -n -t "$JMETER_TEST_PLAN" -l "$RESULTS_FILE" -e -o "$RESULTS_DIR/html_report"

# Check if the test was successful
if [ $? -eq 0 ]; then
    echo "JMeter load test completed successfully."
    echo "Results saved in $RESULTS_FILE"
    echo "HTML Report generated at $RESULTS_DIR/html_report"
else
    echo "JMeter load test failed."
    exit 1
fi
