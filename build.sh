#!/bin/bash

set -eu

VERSION="v1.8.2"
GOMINVERSION="1.20"
NAME="ghcr.io/mrubli/nebula-container"
TAG="${VERSION#v}"

docker build \
	--build-arg VERSION=${VERSION} \
	--build-arg GOMINVERSION=${GOMINVERSION} \
	-t ${NAME}:${TAG} \
	.
docker push ${NAME}:${TAG}
