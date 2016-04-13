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
@test "cache-modules fails if hostDirPath.part exists" {
	mkdir "$remote/$hostDirPath.part"
	run $build/cache-modules
	! [[ $status -eq 0 ]]
	rm -rf "$remote/$hostDirPath.part"
	rm -rf "$remote/$hostTarPath"
	run $build/cache-modules
	[[ $status -eq 0 ]]
}
@test "cache-modules fails if hostTarPath.part exists" {
	touch "$remote/$hostTarPath"
	run $build/cache-modules
	! [[ $status -eq 0 ]]
	rm -rf "$remote/$hostDirPath.part"
	rm -rf "$remote/$hostTarPath"
	run $build/cache-modules
	[[ $status -eq 0 ]]
}
