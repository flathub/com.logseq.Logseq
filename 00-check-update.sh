#!/bin/sh

FLATHUB_VERSION=$(xmllint --xpath "string(//component/releases/release[1]/@version)" com.logseq.Logseq.metainfo.xml)
LATEST_VERSION=$(curl -sS 'https://release-monitoring.org/api/v2/versions/?project_id=291486'|jq -r .latest_version)
FORCE_VERSION=$1

echo "$FLATHUB_VERSION => $LATEST_VERSION"

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
