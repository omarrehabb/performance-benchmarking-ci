#!/bin/bash

# Exit on any failure
set -e

# Function to check if JMeter is installed
check_jmeter_installed() {
  if ! command -v jmeter &> /dev/null; then
      echo "JMeter could not be found, installing JMeter..."
      wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.2.tgz
      tar -xzf apache-jmeter-5.6.2.tgz
      export PATH=$PATH:$(pwd)/apache-jmeter-5.6.2/bin
  else
      echo "JMeter is already installed."
  fi
}

# Ensure JMeter is installed
check_jmeter_installed

# Ensure results directory exists
RESULTS_DIR="./performance_tests/results"
HTML_REPORT_DIR="$RESULTS_DIR/html_report"
mkdir -p "$RESULTS_DIR"

# Define variables
JMETER_TEST_PLAN="./performance_tests/teastore_load_test.jmx"
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl"

# Run JMeter load test
echo "Running JMeter load test on TeaStore services..."
jmeter -n -t "$JMETER_TEST_PLAN" -l "$RESULTS_FILE"

# Check if .jtl file was created
if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: JMeter results file was not created."
    exit 1
fi

# Generate HTML report
echo "Generating HTML report..."
jmeter -g "$RESULTS_FILE" -o "$HTML_REPORT_DIR"

# Verify HTML report creation
if [ $? -eq 0 ]; then
    echo "HTML Report generated at: $HTML_REPORT_DIR"
else
    echo "Error: Failed to generate HTML report."
    exit 1
fi
