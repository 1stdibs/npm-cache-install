# $hostNodeModules, $controlSocket, $ssh, $modulesHash set by common.sh

echo "Conditionally fetching node_modules for $(pwd)"
set -e # exit on error
if [[ -z "$cacheInstallHost" ]]
then
	echo "cacheInstallHost environment variable required"
	exit 1
fi

$ssh -f -M $host sleep 1000 > /dev/null # background ssh control master for subsequent connections
pathToModulesOnHost=${cacheInstallPath}$hostNodeModules
if ! $ssh $host [ -d $pathToModulesOnHost ] &> /dev/null
then
	echo "cache does not exist at $host:${cacheInstallPath}$hostNodeModules"
	$ssh -q -O exit $host 2> /dev/null
	exit 1
fi
$ssh $host "ls -ld $pathToModulesOnHost"
if ! $ssh $host touch -c $pathToModulesOnHost
then
	echo "error when attempting to touch modules on $host at $pathToModulesOnHost"
fi
creditTo=$(userForRemoteFile $hostDirPath)
if [[ "$(whoami)" = "$creditTo" ]]
then
	creditTo="your"
else
	creditTo="$creditTo's"
fi
echo "pulling in $creditTo cache from $host:$pathToModulesOnHost"
$rsync -e "$ssh" --delete -az $host:$pathToModulesOnHost/ node_modules
$ssh -q -O exit $host 2> /dev/null # close the ssh socket
