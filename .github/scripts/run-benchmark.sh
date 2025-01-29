#!/bin/bash
set -e  # Exit immediately on any errors

# Get the absolute path of the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Define variables
JMETER_VERSION="5.6.3"
JMETER_DIR="$REPO_ROOT/.github/tools/apache-jmeter-${JMETER_VERSION}"
RESULTS_DIR="$REPO_ROOT/.github/performance_tests/results"
HTML_REPORT_DIR="$RESULTS_DIR/html_report"
JMETER_TEST_PLAN="$REPO_ROOT/.github/performance_tests/teastore_load_test.jmx"
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl"

# Ensure the JMeter directory exists
if [ ! -d "$JMETER_DIR" ]; then
    echo "Error: JMeter directory not found at $JMETER_DIR. Ensure JMeter is extracted in .github/tools."
    exit 1
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
