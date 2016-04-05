#!/usr/bin/env bats
load helpers
@test 'common sets cacheInstallHost and cacheInstallDest from $HOME/.npm-cache-install' {
	writeDotFile
	cacheInstallDest=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallDest" = "dotfilecacheInstallDest" ]]
	[[ "$cacheInstallHost" = "dotfilecachehost" ]]
}
@test 'common sets cacheInstallHost and cacheInstallDest from package.json when cacheinstall property is present' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"host": "pjhost",
		"path": "pjpath"
	}'
	cacheInstallDest=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallDest" = "pjpath" ]]
	[[ "$cacheInstallHost" = "pjhost" ]]
}
@test 'common unsets cacheInstallDest when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"host": "pjhost"
	}'
	cacheInstallDest=""
	cacheInstallHost=""
	load $build/common
	[[ -z "$cacheInstallDest" ]]
	[[ "$cacheInstallHost" = "pjhost" ]]
}
@test 'common unsets cacheInstallHost when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson '"cacheInstall": {
		"path": "pjpath"
	}'
	cacheInstallDest=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallDest" = "pjpath" ]]
	[[ -z "$cacheInstallHost" ]]
}
