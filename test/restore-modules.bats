#!/usr/bin/env bats
load helpers
@test "restore-modules should fail if cache doesnt exist on remote" {
	! [[ -d $remote/$hostDest$dirName ]]
	run $build/restore-modules
	! [[ $status -eq 0 ]]
}
@test "restore-modules should restore node_modules from remote" {
	# TODO: get this working on travis
	$build/cache-modules
	touch $testPkg/node_modules/shouldnt-be-here
	run diff -r $testPkg/node_modules $remote/$hostDest$dirName
	! [[ $status -eq 0 ]]
	run $build/restore-modules
	[[ $status -eq 0 ]]
	run diff -r $testPkg/node_modules $remote/$hostDest$dirName
	[[ $status -eq 0 ]]
}
