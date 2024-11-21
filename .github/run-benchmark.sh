#!/bin/bash

echo "Starting TeaStore containers for load testing..."

# Start the registry
docker run -d --name teastore-registry -e "HOST_NAME=localhost" -e "SERVICE_PORT=10000" -p 10000:8080 teastore-registry

# Start the database
docker run -d --name teastore-db -p 3306:3306 teastore-db

# Start the persistence service
docker run -d --name teastore-persistence -e "REGISTRY_HOST=localhost" -e "REGISTRY_PORT=10000" -e "HOST_NAME=localhost" -e "SERVICE_PORT=1111" -e "DB_HOST=localhost" -e "DB_PORT=3306" -p 1111:8080 teastore-persistence

# Start the recommender service
docker run -d --name teastore-recommender -e "REGISTRY_HOST=localhost" -e "REGISTRY_PORT=10000" -e "HOST_NAME=localhost" -e "SERVICE_PORT=2222" -p 2222:8080 teastore-recommender

# Start the webUI
docker run -d --name teastore-webui -e "REGISTRY_HOST=localhost" -e "REGISTRY_PORT=10000" -e "HOST_NAME=localhost" -e "SERVICE_PORT=8080" -p 8080:8080 teastore-webui

echo "Waiting for services to initialize..."
sleep 30  

echo "Running load tests..."

# JMeter Command:
jmeter -n -t path_to_your_test.jmx -l results.jtl

echo "Stopping and cleaning up containers..."

# Stop and remove all containers after the test
docker stop teastore-registry teastore-db teastore-persistence teastore-recommender teastore-webui
docker rm teastore-registry teastore-db teastore-persistence teastore-recommender teastore-webui

echo "Load testing complete. Results saved in results.jtl."
