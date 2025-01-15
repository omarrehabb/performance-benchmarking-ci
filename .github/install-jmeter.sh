#!/bin/bash

# Exit on any failure
set -e

# Variables
JMETER_VERSION="5.6.2"
JMETER_URL="https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz"
INSTALL_DIR="/opt/apache-jmeter-${JMETER_VERSION}"

# Download and install JMeter
echo "Downloading Apache JMeter version ${JMETER_VERSION}..."
sudo wget -q $JMETER_URL -O /tmp/apache-jmeter-${JMETER_VERSION}.tgz

echo "Installing JMeter..."
sudo mkdir -p $INSTALL_DIR
sudo tar -xzf /tmp/apache-jmeter-${JMETER_VERSION}.tgz -C /opt

# Add JMeter to PATH
echo "Adding JMeter to PATH..."
echo "export PATH=$INSTALL_DIR/bin:\$PATH" | sudo tee /etc/profile.d/jmeter.sh > /dev/null
source /etc/profile.d/jmeter.sh

# Verify installation
echo "JMeter installed at $INSTALL_DIR"
jmeter -v
