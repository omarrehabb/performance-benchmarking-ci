#!/bin/bash
set -e  # Exit immediately on any errors

# Get the absolute path of the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Define variables
JMETER_VERSION="5.6.2"
JMETER_ARCHIVE="$REPO_ROOT/.github/tools/apache-jmeter-${JMETER_VERSION}.tgz"
JMETER_DIR="$REPO_ROOT/.github/tools/apache-jmeter-${JMETER_VERSION}"
RESULTS_DIR="$REPO_ROOT/.github/performance_tests/results"
HTML_REPORT_DIR="$RESULTS_DIR/html_report"
JMETER_TEST_PLAN="$REPO_ROOT/.github/performance_tests/teastore_load_test.jmx"
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl"

# Ensure the JMeter archive exists
if [ ! -f "$JMETER_ARCHIVE" ]; then
    echo "Error: JMeter archive not found at $JMETER_ARCHIVE. Ensure the file is in .github/tools."
    exit 1
fi

# Extract JMeter if the directory doesn't exist
if [ ! -d "$JMETER_DIR" ]; then
    echo "Extracting JMeter from $JMETER_ARCHIVE..."
    mkdir -p "$REPO_ROOT/.github/tools"
    tar -xzf "$JMETER_ARCHIVE" -C "$REPO_ROOT/.github/tools"
fi

# Add JMeter to PATH
export PATH=$JMETER_DIR/bin:$PATH

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
