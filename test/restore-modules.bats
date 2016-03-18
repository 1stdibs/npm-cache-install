#!/usr/bin/env bats
load helpers
@test "restore-modules should restore node_modules from remote" {
	$build/cache-modules
	touch $testPkg/node_modules/shouldnt-be-here
	run diff -r $testPkg/node_modules $remote/$hostDest$dirName
	! [[ $status -eq 0 ]]
	run $build/restore-modules
	[[ $status -eq 0 ]]
	run diff -r $testPkg/node_modules $remote/$hostDest$dirName
	[[ $status -eq 0 ]]
}
