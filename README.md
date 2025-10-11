# Logseq Flatpak

## For users

### Permissions

By default, Logseq has read-write access to your home directory and uses `~/.logseq` for global config and downloaded plugins.

To restrict access to specific dirs containing your graph(s) (e.g. `~/notes`):

1. Quit Logseq

2. Set these overrides (can also be done with [Flatseal](https://github.com/tchx84/flatseal) GUI):

   ```
   flatpak --user override --nofilesystem=home --filesystem=~/notes --persist=.logseq com.logseq.Logseq
   ```
  
   - `--filesystem` can be specified multiple times for more graph dirs.
  
   - To paste images or other files into Logseq, you'll also need to give access to their dirs. You can give read-only access by appending `:ro` to the path, e.g. `--filesystem=~/photos:ro`

3. If you previously used Logseq, it would have created `~/.logseq`. Move `~/.logseq` to `~/.var/app/com.logseq.Logseq/.logseq`

Note `--persist=.logseq` has no effect unless used together with `--nofilesystem=home`. If Logseq has access to home dir, it will use `~/.logseq`.

## For package maintainers

### How to update to a new version

Set the VERSION environment variable

```shell
export VERSION=0.8.0
```

Download the latest release from <https://github.com/logseq/logseq/releases>

```shell
curl -L -o logseq-$VERSION.tar.gz https://github.com/logseq/logseq/archive/refs/tags/$VERSION.tar.gz
```

Generate the sha256sum

```shell
sha256sum logseq-$VERSION.tar.gz
```

Update the release url and the sha257sum in the `com.logseq.Logseq.json` file.

Uncompress the file

```shell
tar xf logseq-$VERSION.tar.gz
```

Generate missing yarn lock file

```shell
cd logseq-$VERSION/resources
yarn
cp yarn.lock ../../static/yarn.lock
```

Install `flatpak-node-generator` from [flatpak-builder-tools](https://github.com/flatpak/flatpak-builder-tools)

Generate `generated-sources.json`

> Note: First we delete tldraw demo's yarn file, as it is not needed and causes an error: flatpak/flatpak-builder-tools#358

```shell
rm logseq-$VERSION/tldraw/cljs-demo/yarn.lock
flatpak-node-generator -r yarn \
  logseq-$VERSION/yarn.lock --electron-node-headers -o generated-sources.json
```

Finally we may also need to update the clojure dependencies.

First we need to build the new release to force download dependencies.

```shell
rm -rf ~/.m2/repository
cd logseq-$VERSION
yarn
yarn gulp:build && yarn cljs:release-electron
```

Then update the `maven-sources.json` file

```shell
python3 flatpak-clj-generator-from-cache.py > maven-sources.json
```

Finally, test the build

```shell
flatpak-builder --user --install --force-clean build-dir/ com.logseq.Logseq.yml
```

If all goes well, we can commit and push a new release.
