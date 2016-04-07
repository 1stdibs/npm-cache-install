#!/usr/bin/env bats
load helpers
@test 'common sets cacheInstallHost and cacheInstallPath from $HOME/.npm-cache-install' {
	writeDotFile
	cacheInstallPath=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallPath" = "dotfilecacheInstallPath" ]]
	[[ "$cacheInstallHost" = "dotfilecachehost" ]]
}
@test 'common sets cacheInstallHost and cacheInstallPath from package.json when cacheinstall property is present' {
	writeDotFile
	makePackageJson
	cat package.json | jq '.cacheInstall={
		"host": "pjhost",
		"path": "pjpath"
	}' > package.json
	cacheInstallPath=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallPath" = "pjpath" ]]
	[[ "$cacheInstallHost" = "pjhost" ]]
}
@test 'common unsets cacheInstallPath when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson
	cat package.json | jq '.cacheInstall={
		"host": "pjhost"
	}' > package.json
	cacheInstallPath=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallPath" = "/tmp/node_modules-cache/" ]]
	[[ "$cacheInstallHost" = "pjhost" ]]
}
@test 'common unsets cacheInstallHost when it is specified in dotfile but not specified in package.json' {
	writeDotFile
	makePackageJson
	cat package.json | jq '.cacheInstall={
		"path": "pjpath"
	}' > package.json
	cacheInstallPath=""
	cacheInstallHost=""
	load $build/common
	[[ "$cacheInstallPath" = "pjpath" ]]
	[[ "$cacheInstallHost" = "localhost" ]]
}
