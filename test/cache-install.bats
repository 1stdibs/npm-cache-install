#!/usr/bin/env bats
load helpers
@test 'should run run clean install, sign install, and cache modules if restore-module fails' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=1 \
	run $testStart/src/cache-install.sh
	[[ $status -eq 0 ]]
	stat $testTmp/restore-modules-ran
	stat $testTmp/clean-install-ran
	stat $testTmp/cache-sign-install-ran
	stat $testTmp/cache-modules-ran
}
@test 'should only run restore modules if it succeeds' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=0 \
	run $testStart/src/cache-install.sh
	[[ $status -eq 0 ]]
	stat $testTmp/restore-modules-ran
	! stat $testTmp/clean-install-ran
	! stat $testTmp/cache-sign-install-ran
	! stat $testTmp/cache-modules-ran
}
@test 'should exit with failure if nothing succeeds' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=1 \
	cacheSignInstallExitCode=1 \
	cleanInstallExitCode=1 \
	cacheModulesExitCode=1 \
	run $testStart/src/cache-install.sh
	[[ $status -eq 1 ]]
}
