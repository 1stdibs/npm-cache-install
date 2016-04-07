#!/usr/bin/env bats
load helpers
@test "sign-install hash ignores package.json when npm-shrinkwrap.json is present" {
	echo "blah blah its shrinkwrapped" > npm-shrinkwrap.json
	$build/sign-install # stores the finterprint in node_modules/.npm-module-cache.hash
	originalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	cat package.json | jq '.dependencies["a-new-dependency"]="semver-for-another-dependency"' > package.json
	$build/sign-install # recompute the fingerprint after package.json has been chagned
	sameAsOriginalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	[ "$originalFingerprint" = "$sameAsOriginalFingerprint" ]
	echo "blah blah its shrinkwrap changed" > npm-shrinkwrap.json
	$build/sign-install # recompute the fingerprint after npm-shrinkwrap.json has been chagned
	newShrinkwarpFingerprint=$(cat node_modules/.npm-module-cache.hash)
	[ "$originalFingerprint" != "$newShrinkwarpFingerprint" ]
}
@test "sign-install hash changes when dependencies are changed" {
	$build/sign-install # stores the finterprint in node_modules/.npm-module-cache.hash
	stat node_modules/.npm-module-cache.hash
	originalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	cat package.json | jq '.dependencies["foo"]=(.dependencies.foo + ".semversuffix")' > package.json
	$build/sign-install # recompute the fingerprint after package.json has been chagned
	currentFingerprint=$(cat node_modules/.npm-module-cache.hash)
	[ "$originalFingerprint" != "$currentFingerprint" ]
}
@test "sign-install hash changes when devDependencies are changed" {
	$build/sign-install # stores the finterprint in node_modules/.npm-module-cache.hash
	originalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	cat package.json | jq '.devDependencies["dev-foo"]=(.devDependencies["dev-foo"] + ".semversuffix")' > package.json
	$build/sign-install # recompute the fingerprint after package.json has been chagned
	currentFingerprint=$(cat node_modules/.npm-module-cache.hash)
	[ "$originalFingerprint" != "$currentFingerprint" ]
}
@test "sign-install hash does not change when irrelevant properties change in package.json" {
	$build/sign-install # stores the finterprint in node_modules/.npm-module-cache.hash
	originalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	cat package.json | jq '.name="added a name"' > package.json # add some non-hashworthy data to package.json
	$build/sign-install # recompute the fingerprint after pacakge name property has changed
	sameAsOriginalFingerprint=$(cat node_modules/.npm-module-cache.hash)
	$build/sign-install # recompute the fingerprint after package.json has been chagned
	[ "$originalFingerprint" = "$sameAsOriginalFingerprint" ]
}
