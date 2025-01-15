#!/bin/bash

# Exit on any failure
set -e

# Variables
JMETER_VERSION="5.6.2"
JMETER_URL="https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz"
INSTALL_DIR="/opt/apache-jmeter-${JMETER_VERSION}"
RESULTS_DIR="./performance_tests/results"
HTML_REPORT_DIR="$RESULTS_DIR/html_report"
JMETER_TEST_PLAN="./performance_tests/teastore_load_test.jmx"
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl"

# Function to check if JMeter is installed
install_jmeter() {
  if ! command -v jmeter &> /dev/null; then
      echo "JMeter not found. Installing JMeter version ${JMETER_VERSION}..."
      sudo wget -q $JMETER_URL -O /tmp/apache-jmeter-${JMETER_VERSION}.tgz
      sudo mkdir -p $INSTALL_DIR
      sudo tar -xzf /tmp/apache-jmeter-${JMETER_VERSION}.tgz -C /opt
      echo "export PATH=$INSTALL_DIR/bin:\$PATH" | sudo tee /etc/profile.d/jmeter.sh > /dev/null
      source /etc/profile.d/jmeter.sh
      echo "JMeter installed successfully."
  else
      echo "JMeter is already installed."
      jmeter -v
  fi
}

# Install JMeter if necessary
install_jmeter

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"

# Ensure Docker containers are running
echo "Checking Docker containers..."
docker ps | grep teastore
if [ $? -ne 0 ]; then
    echo "TeaStore containers are not running. Ensure the services are up before running the benchmark."
    exit 1
fi

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
    echo "HTML Report generated successfully."
    echo "HTML Report location: $HTML_REPORT_DIR"
else
    echo "Error: Failed to generate HTML report."
    exit 1
fi
