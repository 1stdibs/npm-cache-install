setup() {
	export cacheInstallHost="mockhost"
	export cacheInstallDest="./"
	export build="$(pwd)/build"
	export testStart=$(pwd)
	export testTmp="$testStart/testTmp"
	export testPkg="$testTmp/pkg"
	export remote="$testTmp/remote"
	export PATH="$testStart/test/bin-mock:$PATH"
	export HOME=$testTmp
	mkdir -p $testPkg
	mkdir -p $remote
	cd $testPkg
	makePackageJson
	mkdir -p node_modules
	source $build/common
}
teardown() {
	cd $testStart
	rm -rf testtmp
}
makePackageJson() {
	extra=""
	if [[ -n "$1" ]]
	then
		extra="$1,"
	fi
	cat << json > package.json
{
	$extra
	"dependencies": {
		"foo": "1.0.0",
		"bar": "1.0.0"
	},
	"devDependencies": {
		"dev-foo": "1.0.0",
		"dev-bar": "1.0.0"
	}
}
json
}
writeDotFile() {
	echo $HOME/.npm-cache-install
	cat > $HOME/.npm-cache-install << DOTFILE
export cacheInstallDest="dotfilecacheInstallDest"
export cacheInstallHost="dotfilecachehost"
DOTFILE
}
