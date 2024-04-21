#!/bin/bash

set -eu

VERSION="v1.8.2"
GOMINVERSION="1.20"
NAME="ghcr.io/mrubli/nebula-container"
TAG="${VERSION#v}"

docker build \
	--build-arg VERSION=${VERSION} \
	--build-arg GOMINVERSION=${GOMINVERSION} \
	--platform=linux/amd64,linux/arm64,linux/arm/v7 \
	--annotation "index:org.opencontainers.image.description=Multi-arch image for Nebula. Nebula is a scalable overlay networking tool with a focus on performance, simplicity and security from Slack." \
	--tag ${NAME}:${TAG} \
	--push \
	.
