#!/usr/bin/env bats
load helpers
@test "restore-modules should fail if cache doesnt exist on remote" {
	! [[ -d $remote/$hostDest$dirName ]]
	run $build/restore-modules
	! [[ $status -eq 0 ]]
}
