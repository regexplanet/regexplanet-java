#!/usr/bin/env bash
#
# run the docker container version locally
#

set -o errexit
set -o pipefail
set -o nounset

if false ; then
docker run \
	--detach \
	--name regexplanet-java \
	--publish 4000:8080 \
	--volume "${PWD}/src/main/webapp:/var/lib/jetty/webapps/ROOT" \
	jetty:latest


exit 0
fi

docker build -t regexplanet-java .


docker run \
	--expose 4000 \
	--env COMMIT=$(git rev-parse --short HEAD)-local \
	--env LASTMOD=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
	--env PORT='4000' \
	--publish 4000:8080 \
	regexplanet-java

