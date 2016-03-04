echo "Conditionally caching node_modules for $(pwd)"
set -e # exit on error
if [[ -z "$npmCacheHost" ]]
then
	echo "npmCacheHost environment variable required"
	exit 1
fi

hostDest='.npmbuildcache/'
delim='-'
host=$npmCacheHost
hostDest='.npmbuildcache/'
controlSocket=/tmp/ssh-socket-$host-$(date +%s)
if which gtar
then
	tar="gtar"
else
	tar="tar"
	if [[ $(uname -s) == "Darwin" ]]
	then
		echo "Install gnu-tar to avoid \"Ignoring unknown extended header keyword\" errors."
	fi
fi
ssh="ssh -S $controlSocket"
scp="scp -o ControlPath=$controlSocket"

unameHash=$(uname -mprsv | shasum | cut -c 1-40)
pjHash=$(node -e "var pj=($(cat package.json)); console.log({dependencies: pj.dependencies, devDependencies: pj.devDependencies})" | shasum | cut -c 1-40)
modulesHash="DEPS${pjHash}${delim}ARCH${unameHash}"

dirName=node_modules-$modulesHash
tarName=$dirName.tgz
tarPath=/tmp/$tarName
hostTarPath=$hostDest$tarName
hostDirPath=$hostDest$dirName
$ssh -f -M $host sleep 1000 > /dev/null # background ssh control master for subsequent connections
set +e # no exit on error
$ssh $host stat $hostDirPath &> /dev/null
exists=$?
set -e # exit on error
send=true
if [[ -z "$forceUpload" && $exists -eq 0 ]]
then
	$ssh -q -O exit $host 2> /dev/null # close the ssh socket
	exit
fi
echo "Hash for your package.json is $modulesHash"
echo "Creating tgz of your node_modules in $tarPath. This may take a while if node_nodules is big."
tar czf $tarPath node_modules
$ssh $host "mkdir -p $hostDest"
echo "uploading $tarPath to $host:$hostTarPath"
$scp $tarPath $host:$hostTarPath
rm $tarPath
echo "extracting your node_modules directory on $host at $hostDirPath"
$ssh -T $host << script
	rm -rf $hostDirPath
	mkdir $hostDirPath
	tar xzf $hostTarPath -C $hostDirPath --strip-components 1
	rm -f $hostTarPath
script
echo "your current node_modules directory is now cached on $host at $hostDirPath"
$ssh -q -O exit $host 2> /dev/null # close the ssh socket
