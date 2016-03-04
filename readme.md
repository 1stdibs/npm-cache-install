# npm-build-cache

npm scripts for caching and retrieving node_modules.

## installation

```js
npm install --save-dev npm-build-cache
```

`npm-build-cache` scripts can also be installed globally with the `-g` flag.

Recomended script in `package.json`:
```json
{
    "scripts": {
        "cacheinstall": "restore-modules || cleaninstall && cache-modules"
    }
}
```

## the scripts

###`cache-modules`

Uses ssh and scp to conditionally upload `node_modules` to `$npmCacheHost` as node_modules-DEPS${shasum of package.json}-ARCH${shasum of uname -mprsv}.

Environment variables:
* `npmCacheHost` - name of host for cached `node_modules`.
* `forceUpload` - if defined, the existence of `node_modules` on `npmCacheHost` will be ignored and `node_modules` will always be uploaded.

Recomendations:

* configure authentication via ssh keys between your machine and `npmCacheHost` so you don't have to type your password every time this script is run.
* Install a cronjob on the cache host that removes old cached `node_modules` directories. `preinstall.sh` touches the directory before downloading, so it should be sufficient to order the cached `node_modules` directories by date and `rm -rf` remove all but the first _N_.


### `restore-modules`

rsyncs the cached `node_modules` from the cache host to your machine, according to the current package.json and your machine's architecture.

Environment variables:
* `npmCacheHost` - name of host for cached `node_modules`.

Notes:
* This script will `touch` the `node_modules` directory on the cache host before rsyncing it so it can be identified as recently used.