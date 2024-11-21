#!/bin/bash

# Variables
WEBUI_HOST="127.0.0.1"
WEBUI_PORT="8080"
DURATION="30s"    # Duration for the load test
THREADS=4         # Number of threads
CONNECTIONS=100   # Number of connections

echo "Running load test on TeaStore WebUI at http://${WEBUI_HOST}:${WEBUI_PORT}"

# Run wrk load test
wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION} http://${WEBUI_HOST}:${WEBUI_PORT}/tools.descartes.teastore.webui/

echo "Load test completed."
