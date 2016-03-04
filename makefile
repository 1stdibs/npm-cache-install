all : build/cache-modules build/restore-modules build/post-install
build :
	mkdir -p build
tmp : 
	mkdir -p tmp
tmp/common.sh : tmp
	cat src/common.sh > tmp/common.sh
	chmod a+x tmp/common.sh
build/cache-modules : tmp/common.sh build
	cat tmp/common.sh src/npm-cache-modules.sh > build/cache-modules
	chmod a+x build/cache-modules
build/restore-modules : tmp/common.sh build
	cat tmp/common.sh src/npm-restore-modules.sh > build/restore-modules
	chmod a+x build/restore-modules
build/post-install : tmp/common.sh build
	cat tmp/common.sh src/post-install.sh > build/post-install
	chmod a+x build/post-install
clean :
	rm -rf tmp build
