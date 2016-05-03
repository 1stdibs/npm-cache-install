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
@test 'should exit with failure if cache-modules failes and okIfCacheFailed is falsy' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=1 \
	cacheSignInstallExitCode=0 \
	cleanInstallExitCode=0 \
	cacheModulesExitCode=1 \
	run $testStart/src/cache-install.sh
	[[ $status -eq 1 ]]
}
@test 'should exit with failure if cache-modules failes and okIfCacheFailed is truthy' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=1 \
	cacheSignInstallExitCode=0 \
	cleanInstallExitCode=0 \
	cacheModulesExitCode=1 \
	okIfCacheFailed=1 \
	run $testStart/src/cache-install.sh
	[[ $status -eq 0 ]]
}
@test 'should not run npm-cache-modules if npm-clean-install fails' {
	globalInstallPackage
	stubCacheInstallScripts
	restoreModulesExitCode=1 \
	cacheSignInstallExitCode=0 \
	cleanInstallExitCode=1 \
	cacheModulesExitCode=0 \
	run $testStart/src/cache-install.sh
	stat $testTmp/clean-install-ran
	! stat $testTmp/cache-modules-ran
	[[ $status -eq 1 ]]
}
