setup() {
	export build="$(pwd)/build"
	export testStart=$(pwd)
	export testTmp=$testStart/testtmp
	export PATH="$testStart/test/bin-mock:$PATH"
	mkdir -p $testTmp
	cd $testTmp
	makePackageJson
	mkdir -p node_modules
	source $build/common
}
teardown() {
	cd $testStart
	rm -rf testtmp
}
makePackageJson() {
	cat << json > package.json
{
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
