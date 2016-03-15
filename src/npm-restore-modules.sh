# $hostNodeModules, $controlSocket, $ssh, $modulesHash set by common.sh

echo "Conditionally fetching node_modules for $(pwd)"
set -e # exit on error
if [[ -z "$npmCacheHost" ]]
then
	echo "npmCacheHost environment variable required"
	exit 1
fi
if [[ -z "$hostDest" ]]
then
	hostDest='/tmp/node_modules-cache/'
fi

$ssh -f -M $host sleep 1000 > /dev/null # background ssh control master for subsequent connections
set +e # disable exit on error
pathToModulesOnHost=${hostDest}$hostNodeModules
$ssh $host [ -d $pathToModulesOnHost ] &> /dev/null
cacheExists=$?
set -e # enable exit on error
if [[ $cacheExists -ne 0 ]]
then
	echo "cache does not exist at $host:${hostDest}$hostNodeModules"
	exit $cacheExists
fi
if ! $ssh $host touch -c $pathToModulesOnHost
then
	echo "error when attempting to touch modules on $host at $pathToModulesOnHost"
fi
echo "pulling in your new modules from $pathToModulesOnHost"
$rsync -e "$ssh" --delete -az $host:$pathToModulesOnHost/ node_modules
$ssh -q -O exit $host 2> /dev/null # close the ssh socket
