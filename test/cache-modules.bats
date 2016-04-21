#!/usr/bin/env bats
load helpers
@test "cache-modules does not attempt to recache modules if they are already present in the cache" {
	run $build/sign-install
	$build/cache-modules
	cp -R $remote/$cacheInstallPath$hostDirPath $remote/$cacheInstallPath$hostDirPath-stashed
	rm -rf $remote/$cacheInstallPath$hostDirPath/*
	$build/cache-modules # bats run doesnt allow setting inline environment variables
	! diff $remote/$cacheInstallPath$hostDirPath $remote/$cacheInstallPath$hostDirPath-stashed
}
@test "cache-modules does attempt to recache modules if they are already present in the cache and forceUpload is set" {
	run $build/sign-install
	$build/cache-modules
	cp -R $remote/$cacheInstallPath$hostDirPath $remote/$cacheInstallPath$hostDirPath-stashed
	rm -rf $remote/$cacheInstallPath$hostDirPath/*
	touch $remote/$cacheInstallPath$hostDirPath/something-in-here
	forceUpload=true $build/cache-modules # bats run doesnt allow setting inline environment variables
	diff $remote/$cacheInstallPath$hostDirPath $remote/$cacheInstallPath$hostDirPath-stashed
}
@test "cache-modules copies node_modules over to the remote" {
	run $build/sign-install
	run $build/cache-modules # copies node_modules and exports hostDirPath so we know where to look
	diff -r $testPkg/node_modules $remote/$cacheInstallPath$dirName
}
@test "cache-modules fails if hostDirPath.part exists and is under staleDirectoryLimitMinutes minutes old" {
	mkdir "$remote/$hostDirPath.part"
	run $build/cache-modules
	! [[ $status -eq 0 ]]
	rm -rf "$remote/$hostDirPath.part"
	rm -rf "$remote/$hostTarPath"
	run $build/cache-modules
	[[ $status -eq 0 ]]
}
@test "cache-modules does not fail if hostDirPath.part exists and is staleDirectoryLimitMinutes minutes old or older" {
	mkdir "$remote/$hostDirPath.part"
	setInThePast "$remote/$hostDirPath.part" $((staleDirectoryLimitMinutes + 1))
	$build/cache-modules
}
@test "cache-modules fails if hostTarPath.part exists and is under stalePartialTarMinutes minutes old" {
	touch "$remote/$hostTarPath.part" # under $stalePartialTarMinutes minutes old
	! $build/cache-modules
	rm -rf "$remote/$hostTarPath.part"
	rm -rf "$remote/$hostDirPath.part"
	rm -rf "$remote/$hostTarPath"
	$build/cache-modules
}
@test "cache-modules does not fail if hostTarPath.part exists and is stalePartialTarMinutes minutes old or older" {
	touch "$remote/$hostTarPath.part"
	setInThePast "$remote/$hostTarPath.part" $((stalePartialTarMinutes + 1))
	$build/cache-modules
}
