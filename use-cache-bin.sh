pushd node_modules/npm-build-cache
dn=$(pwd)
popd
$dn/use-cache.sh $@
