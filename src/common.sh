delim='-'
host=$npmCacheHost
packageJson=$(cat package.json)
if [[ -z "$packageJson" ]]
then
	echo "package.json must be in cwd"
	exit 1
fi
pjHash=$(node << jscode | shasum | cut -c 1-40
with ($packageJson) {
	console.log({
		dependencies: dependencies,
		devDependencies: devDependencies
	})
}
jscode
)
unameHash=$(uname -mps | shasum | cut -c 1-40)
modulesHash="DEPS${pjHash}${delim}ARCH${unameHash}"
hostNodeModules="node_modules-$modulesHash"
controlSocket="/tmp/ssh-socket-$host-$(date +%s)"
ssh="ssh -S $controlSocket"
scp="scp -o ControlPath=$controlSocket"
hashFilePath="node_modules/.npm-module-cache.hash"
export dirName=node_modules-$modulesHash
export tarName=$dirName.tgz
export hostDirPath=$hostDest$dirName
export hostTarPath=$hostDest$tarName
if [[ $(rsync --version | head -n1 | cut -f4 "-d " | cut -d. -f1) -gt 2 ]]
then
	rsync="rsync -h --info=progress2"
else
	echo "install rsync 3 or later for detailed progress"
	rsync="rsync -h"
fi
