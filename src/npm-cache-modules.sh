# $host, $ssh, scp, $unameHash, $modulesHash, $pjHash, $hostTarPath, $hostDirPath, $tarName, $dirName set by common.sh

if [[ -e $hashFilePath && $pjHash != $(cat $hashFilePath) ]]
then
	echo "$hashFilePath is not consistent with the hash of your package.json file. Either bring back the package.json that was used to install them, or re-install your node_modules."
	exit 1
fi

echo "Conditionally caching node_modules for $(pwd)"
set -e # exit on error

if [[ -z "$cacheInstallPath" ]]
then
	cacheInstallPath='/tmp/node_modules-cache/'
fi
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

tmp=".npm-build-cache-tmp"
mkdir -p $tmp
tarPath=$tmp/$tarName
openSSHSocket
if [[ -z "$forceUpload" ]] && ( $ssh $host stat $hostDirPath &> /dev/null )
then
	echo "node_modules for your package.json have already been cached"
	closeSSHSocket
	exit
fi
echo "Hash for your package.json is $modulesHash"
echo "Creating tgz of your node_modules in $tarPath. This may take a while if node_nodules is big."
$tar czf $tarPath node_modules
$ssh $host "mkdir -p $cacheInstallPath"
$ssh -T $host << script
	find "$hostTarPath.part" -maxdepth 1 -mmin +$stalePartialTarMinutes -exec rm -f {} \; &> /dev/null || true # remove .tar.part uploads older than 2 minutes
	find "$hostTarPath" -maxdepth 1 -mmin +$staleCompleteTarMinutes -exec rm -f {} \; &> /dev/null || true # remove .tar files older than $staleCompleteTarMinutes minutes
script
if $ssh $host stat $hostTarPath &> /dev/null
then
	echo "$(userForRemoteFile $hostTarPath) may be in the middle of uploading $hostTarPath."
	echo "Try again in $staleCompleteTarMinutes minutes."
	closeSSHSocket
	exit 1
fi
if $ssh $host stat $hostTarPath.part &> /dev/null # test upload in-progress
then
	echo "$(userForRemoteFile $hostTarPath.part) may be waiting for their script to finish extracting $hostTarPath.part."
	echo "Try again in $stalePartialTarMinutes minutes."
	closeSSHSocket
	exit 1
fi
echo "uploading $tarPath to $host:$hostTarPath"
$scp $tarPath $host:$hostTarPath.part
$ssh $host mv $hostTarPath.part $hostTarPath
rm -rf $tarPath $tmp
echo "extracting your node_modules directory on $host at $hostDirPath"
$ssh -T $host << script
	find "$hostDirPath.part" -maxdepth 1 -mmin +$staleDirectoryLimitMinutes -exec rm -rf {} \; &> /dev/null || true # remove stale aprtially extracted node_modules
script
if $ssh $host "[[ -e $hostDirPath.part ]]"
then
	echo "$(userForRemoteFile "$hostDirPath.part") may be waiting for $hostDirPath.part to be extracted on $host. Try again in $staleDirectoryLimitMinutes minutes"
	closeSSHSocket
	exit 1
fi
$ssh -T $host << script
	rm -rf $hostDirPath $hostDirPath.part
	mkdir $hostDirPath.part
	tar xzf $hostTarPath -C $hostDirPath.part --strip-components 1
	mv $hostDirPath.part $hostDirPath
	rm -f $hostTarPath
script
echo "your current node_modules directory is now cached on $host at $hostDirPath"
closeSSHSocket
