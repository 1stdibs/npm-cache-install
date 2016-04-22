#!/usr/bin/env bash
if ! npm-restore-modules
then
    echo "node_modules could not be restored from the cache server, so a clean install will be created and cached to the server"
    npm-clean-install
    npm-build-cache-sign-install
    npm-cache-modules
fi
