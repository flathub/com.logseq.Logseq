#!/bin/sh

FLATHUB_VERSION=$(curl 'https://release-monitoring.org/api/v2/packages/?name=com.logseq.Logseq&distribution=Flathub'|jq -r '.items[].version')
LATEST_VERSION=$(curl 'https://release-monitoring.org/api/v2/versions/?project_id=291486'|jq -r .latest_version)
FORCE_VERSION=$1

if test -z "$FORCE_VERSION"; then
    VERSION=$LATEST_VERSION
    if test $FLATHUB_VERSION = $VERSION; then
        echo "::set-output name=up_to_date::true"
        echo "Already up to date."
        exit
    fi
else
    VERSION=$FORCE_VERSION
fi
