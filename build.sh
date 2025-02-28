#!/bin/bash
# packages handlers

set -e

# A fallback version when run outside of CI. Will look like: 2.2.1-13-gd591456
# 2.2.1 - most recent tag with the leading v trimmed
# 13 - no.of commits away from tag
# gd591456 - this commit's id
GIT_VERSION="`git describe | sed -e s/^v//`"
VERSION="${CIRCLE_TAG:-$GIT_VERSION}"

ROOT_DIR=$(pwd)
rm -rf pkg
mkdir pkg

HANDLERS="cloudwatch-handler s3-handler sns-handler mysql-handler postgresql-handler publisher"

for HANDLER in ${HANDLERS}; do
	cd ${HANDLER}
	GOARCH=amd64 GOOS=linux CGO_ENABLED=0 go build -ldflags "-X github.com/honeycombio/agentless-integrations-for-aws/common.version=jijo_test"
	chmod +x ${HANDLER}
	cd ${ROOT_DIR}
	mv ${HANDLER}/${HANDLER} pkg
done;

cd ./pkg

zip ingest-handlers.zip *
