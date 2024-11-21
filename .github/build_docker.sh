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
docker build -t "${registry}teastore-db" .github/utilities/tools.descartes.teastore.database/
docker build -t "${registry}teastore-kieker-rabbitmq" .github/utilities/tools.descartes.teastore.kieker.rabbitmq/
docker build -t "${registry}teastore-base" .github/utilities/tools.descartes.teastore.dockerbase/

# Update FROM statements in Dockerfiles to replace registry name if provided
perl -i -pe's|.*FROM descartesresearch/|FROM '"${registry}"'|g' .github/services/tools.descartes.teastore.*/Dockerfile


docker build -t "${registry}teastore-registry" .github/services/tools.descartes.teastore.registry/
docker build -t "${registry}teastore-persistence" .github/services/tools.descartes.teastore.persistence/
docker build -t "${registry}teastore-image" .github/services/tools.descartes.teastore.image/
docker build -t "${registry}teastore-webui" .github/services/tools.descartes.teastore.webui/
docker build -t "${registry}teastore-auth" .github/services/tools.descartes.teastore.auth/
docker build -t "${registry}teastore-recommender" .github/services/tools.descartes.teastore.recommender/
perl -i -pe's|.*FROM '"${registry}"'|FROM descartesresearch/|g' .github/services/tools.descartes.teastore.*/Dockerfile




# Reset FROM statement back to the original after build if needed
perl -i -pe's|.*FROM '"${registry}"'|FROM descartesresearch/|g' ../services/tools.descartes.teastore.*/Dockerfile
