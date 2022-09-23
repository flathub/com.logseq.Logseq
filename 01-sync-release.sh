#!/bin/sh

set -x

VERSION=$1
BASE_URL=https://github.com/logseq/logseq/archive/refs/tags

curl -L -o logseq-$VERSION.tar.gz $BASE_URL/$VERSION.tar.gz

SHA256SUM=$(sha256sum logseq-$VERSION.tar.gz | cut -d " " -f 1)

sed -i "s,\(url: \).*\( \# LOGSEQ_URL\),\1$BASE_URL/$VERSION.tar.gz\2," com.logseq.Logseq.yml
sed -i "s/\(sha256: \).*\( \# LOGSEQ_CHECKSUM\)/\1$SHA256SUM\2/" com.logseq.Logseq.yml

tar xf logseq-$VERSION.tar.gz
cd logseq-$VERSION/resources
yarn
cp yarn.lock ../../static/yarn.lock
cd ../..

flatpak-node-generator -r yarn \
  logseq-$VERSION/yarn.lock --electron-node-headers -o generated-sources.json

rm -rf ~/.m2/repository
cd logseq-$VERSION
yarn
yarn gulp:build && yarn cljs:release-electron
cd ..

python3 flatpak-clj-generator-from-cache.py > maven-sources.json
