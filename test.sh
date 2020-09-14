#!/bin/bash

set -e

BASE_IMAGE="<FIXME>/parent:latest"
CHILD_IMAGE="<FIXME>/child:latest"

# clean up
./cleanup.sh

# Turn on buildkit

export DOCKER_BUILDKIT=1

echo "**************  Building parent image."
docker build \
    -f Dockerfile-parent \
    -t ${BASE_IMAGE} \
    .

docker push ${BASE_IMAGE}

echo ""
echo "**************  Building child image for cache purposes."
docker build \
    -f Dockerfile-child    \
    --build-arg base="$BASE_IMAGE" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --secret id=ssh_key,src=$(pwd)/secret1.txt \
    -t ${CHILD_IMAGE} \
    .

docker push ${CHILD_IMAGE}

echo ""
echo "**************  Listing files from the child image for cache purposes"
docker run ${CHILD_IMAGE} ls

# cleanup
./cleanup.sh

echo ""
echo "**************  Building child image"


# build child image that inherits from base image, with buildkit and caching
docker build \
    -f Dockerfile-child    \
    --build-arg base="${BASE_IMAGE}" \
    --cache-from ${CHILD_IMAGE}  \
    --secret id=ssh_key,src=$(pwd)/secret1.txt \
    -t ${CHILD_IMAGE} \
    .

echo ""
echo "**************  Listing files from the child image"
docker run ${CHILD_IMAGE} ls
