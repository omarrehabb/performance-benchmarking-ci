#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Set repository root dynamically (GitHub Actions or local execution)
REPO_ROOT=${GITHUB_WORKSPACE:-$(git rev-parse --show-toplevel)}

# Define JMeter variables
JMETER_VERSION="5.6.3"
JMETER_DIR="$REPO_ROOT/.github/tools/apache-jmeter-${JMETER_VERSION}"
RESULTS_DIR="$REPO_ROOT/.github/performance_tests/results"
HTML_REPORT_DIR="$RESULTS_DIR/html_report"
JMETER_TEST_PLAN="$REPO_ROOT/.github/performance_tests/teastore_load_test.jmx"
RESULTS_FILE="$RESULTS_DIR/results_$(date +%Y%m%d_%H%M%S).jtl"

echo "Checking JMeter directory: $JMETER_DIR"

# Ensure JMeter directory exists
if [ ! -d "$JMETER_DIR" ]; then
    echo " Error: JMeter directory not found at $JMETER_DIR. Ensure JMeter is extracted in .github/tools."
    exit 1
fi

# Ensure JMeter JAR file exists
if [ ! -f "$JMETER_DIR/bin/ApacheJMeter.jar" ]; then
    echo " Error: JMeter JAR file not found at $JMETER_DIR/bin/ApacheJMeter.jar."
    exit 1
fi

# Grant execute permission only to ApacheJMeter.jar
chmod +x "$JMETER_DIR/bin/ApacheJMeter.jar"

# Add JMeter to PATH
export PATH="$JMETER_DIR/bin:$PATH"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"
mkdir -p "$HTML_REPORT_DIR"

echo "Checking results directory before running JMeter:"
ls -l "$RESULTS_DIR"

# Ensure Docker containers are running
echo "🛠 Checking Docker containers..."
if ! docker ps | grep teastore; then
    echo "Error: TeaStore containers are not running. Ensure the services are up before running the benchmark."
    exit 1
fi

# Run JMeter load test
echo " Running JMeter load test on TeaStore services..."
jmeter -n -t "$JMETER_TEST_PLAN" -l "$RESULTS_FILE"

# Verify that JMeter created the results file
if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: JMeter results file was NOT created at $RESULTS_FILE"
    echo "Checking results directory after running JMeter:"
    ls -l "$RESULTS_DIR"
    exit 1
fi

echo "JMeter results file created successfully at: $RESULTS_FILE"

# Generate HTML report
echo " Generating HTML report..."
jmeter -g "$RESULTS_FILE" -o "$HTML_REPORT_DIR"

# Verify HTML report creation
if [ $? -eq 0 ]; then
    echo " JMeter load test completed successfully."
    echo "Results saved in: $RESULTS_FILE"
    echo "HTML Report generated at: $HTML_REPORT_DIR"
else
    echo "Error: Failed to generate HTML report."
    exit 1
fi
