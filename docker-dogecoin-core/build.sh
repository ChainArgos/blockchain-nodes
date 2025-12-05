#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

export PACKAGE="dogecoin-core"
export DOCKER_IMAGE_VERSION="1.14.8-1"
export DOCKER_REPOSITORY="donbeave/${PACKAGE}"

if [[ -z "${DOCKER_REPOSITORY}" ]]; then
  printf "\e[1;91mERROR\e[0m: DOCKER_REPOSITORY is not set\n"
  exit 1
fi

printf "> \e[1;37mBuilding docker\e[0m\n"

export DOCKER_BUILD_EXTRA_ARGS=${DOCKER_BUILD_EXTRA_ARGS:-"--progress plain"}

echo "Building amd64"

docker buildx build ${DOCKER_BUILD_EXTRA_ARGS} \
  --pull \
  --push \
  --provenance=false \
  --platform linux/amd64 \
  -t "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}-amd64" \
  -f Dockerfile.amd64 .

echo "Building arm64"

docker buildx build ${DOCKER_BUILD_EXTRA_ARGS} \
  --pull \
  --push \
  --provenance=false \
  --platform linux/arm64 \
  -t "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}-arm64" \
  -f Dockerfile.arm64 .

echo "Creating manifest"

docker manifest create -a "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}" \
  "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}-amd64" \
  "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}-arm64"

echo "Pushing manifest"

docker manifest push -p "${DOCKER_REPOSITORY}:${DOCKER_IMAGE_VERSION}"
