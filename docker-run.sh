#!/usr/bin/env bash
#
# run locally but in docker

set -o errexit
set -o pipefail
set -o nounset

docker build \
	--build-arg COMMIT=$(git rev-parse --short HEAD)-local \
	--build-arg LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
	--tag regexplanet-java \
	.

docker run \
	--publish 4000:4000 \
	--expose 4000 \
	--env SERVER_PORT='4000' \
	regexplanet-java
