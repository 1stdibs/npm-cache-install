delim='-'
packageJson=$(cat package.json)
if [[ -z "$packageJson" ]]
then
	echo "package.json must be in cwd"
	exit 1
fi
if [[ -e $HOME/.npm-cache-install ]]
then
	source $HOME/.npm-cache-install
fi
cacheInstallFromPackageJson=$(node -e "console.log(($packageJson).cacheInstall)")
if [[ "undefined" != "$cacheInstallFromPackageJson" ]]
then
	echo cacheInstallFromPackageJson $cacheInstallFromPackageJson
	# let (package.json).cacheInstall override values in .npm-cache-install
	export cacheInstallHost=$(node -e "console.log(($packageJson).cacheInstall.host || '')")
	export cacheInstallPath=$(node -e "console.log(($packageJson).cacheInstall.path || '')")
fi
if [[ -z "$cacheInstallHost" ]]
then
	cacheInstallHost='localhost'
fi
if [[ -z "$cacheInstallPath" ]]
then
	cacheInstallPath='/tmp/node_modules-cache/'
fi
host=$cacheInstallHost
if [[ -e "npm-shrinkwrap.json" ]]
then
	thingToHash=$(cat npm-shrinkwrap.json)
else
	thingToHash=$(node << jscode
with ($packageJson) {
	dependencies = 'undefined' !== typeof dependencies ? dependencies : undefined;
	devDependencies = 'undefined' !== typeof devDependencies ? devDependencies: undefined;
	console.log({
		dependencies: dependencies,
		devDependencies: devDependencies
	});
}
jscode
)
fi
pjHash=$(echo $thingToHash | shasum | cut -c 1-40)
unameHash=$(uname -mps | shasum | cut -c 1-40)
modulesHash="DEPS${pjHash}${delim}ARCH${unameHash}"
hostNodeModules="node_modules-$modulesHash"
controlSocket="/tmp/ssh-socket-$host-$(date +%s)"
ssh="ssh -S $controlSocket"
scp="scp -o ControlPath=$controlSocket"
hashFilePath="node_modules/.npm-module-cache.hash"
export dirName=node_modules-$modulesHash
export tarName=$dirName.tgz
export hostDirPath=$cacheInstallPath$dirName
export hostTarPath=$cacheInstallPath$tarName
export staleDirectoryLimitMinutes="10"
export staleCompleteTarMinutes="10"
export stalePartialTarMinutes="2"
rsync="rsync -h"
if $rsync --dry-run --info=progress2 . . &> /dev/null # test rsync for progress display support
then
	rsync="$rsync --info=progress2"
fi
export rsync
openSSHSocket() {
	$ssh -f -M $host sleep 1000 > /dev/null # background ssh control master for subsequent connections
}
closeSSHSocket() {
	$ssh -q -O exit $host 2> /dev/null # close the ssh socket
}
userForRemoteFile() {
	echo $($ssh $host "ls -ld '$1'" | awk '{print $3}')
}
if touch -A00 /dev/null &> /dev/null
then
	setInThePast() {
		file=$1
		amount=$2
		touch -A-$(printf "%02d" $amount)00 "$file"
	}
else
	setInThePast() {
		file=$1
		amount=$2
		touch -d "-$amount minute" "$file"
	}
fi
