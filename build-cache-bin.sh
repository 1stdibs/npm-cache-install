pushd node_modules/npm-build-cache
dn=$(pwd)
popd
$dn/build-cache.sh $@
