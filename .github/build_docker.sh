#!/bin/bash

# This script builds all Docker images for TeaStore

print_usage() {
  printf "Usage: build_docker.sh [-r REGISTRY_NAME]\n"
}

# Parse options (e.g., passing a registry name if needed)
while getopts 'r:' flag; do
  case "${flag}" in
    r) registry="${OPTARG}" ;;  # Allows custom registry name if needed
    *) print_usage
       exit 1 ;;
  esac
done

# Default to no registry
registry="${registry:-}"

# Building all necessary Docker containers
docker build -t "${registry}teastore-db" ../utilities/tools.descartes.teastore.database/
docker build -t "${registry}teastore-kieker-rabbitmq" ../utilities/tools.descartes.teastore.kieker.rabbitmq/
docker build -t "${registry}teastore-base" ../utilities/tools.descartes.teastore.dockerbase/

# Update FROM statements in Dockerfiles to replace registry name if provided
perl -i -pe's|.*FROM descartesresearch/|FROM '"${registry}"'|g' ../services/tools.descartes.teastore.*/Dockerfile

docker build -t "${registry}teastore-registry" ../services/tools.descartes.teastore.registry/
docker build -t "${registry}teastore-persistence" ../services/tools.descartes.teastore.persistence/
docker build -t "${registry}teastore-image" ../services/tools.descartes.teastore.image/
docker build -t "${registry}teastore-webui" ../services/tools.descartes.teastore.webui/
docker build -t "${registry}teastore-auth" ../services/tools.descartes.teastore.auth/
docker build -t "${registry}teastore-recommender" ../services/tools.descartes.teastore.recommender/

# Reset FROM statement back to the original after build if needed
perl -i -pe's|.*FROM '"${registry}"'|FROM descartesresearch/|g' ../services/tools.descartes.teastore.*/Dockerfile
