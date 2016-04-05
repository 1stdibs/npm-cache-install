#!/usr/bin/env bats
load helpers
@test 'common sets npmCacheHost and hostDest from $HOME/.npm-cache-install' {
	writeDotFile
	hostDest=""
	npmCacheHost=""
	load $build/common
	[[ "$hostDest" = "dotfilehostdest" ]]
	[[ "$npmCacheHost" = "dotfilecachehost" ]]
}
@test 'common sets npmCacheHost and hostDest from package.json when cacheinstall property is present' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"host": "pjhost",
		"path": "pjpath"
	}'
	hostDest=""
	npmCacheHost=""
	load $build/common
	[[ "$hostDest" = "pjpath" ]]
	[[ "$npmCacheHost" = "pjhost" ]]
}
@test 'common unsets hostDest when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"host": "pjhost"
	}'
	hostDest=""
	npmCacheHost=""
	load $build/common
	[[ -z "$hostDest" ]]
	[[ "$npmCacheHost" = "pjhost" ]]
}
@test 'common unsets npmCacheHost when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"path": "pjpath"
	}'
	hostDest=""
	npmCacheHost=""
	load $build/common
	[[ "$hostDest" = "pjpath" ]]
	[[ -z "$npmCacheHost" ]]
}
