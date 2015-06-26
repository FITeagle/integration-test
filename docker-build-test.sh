#!/bin/sh

echo "docker build tests..."

_CACHE_DIR=$(pwd)"/m2_cache"

runcmd() {
	echo "cmd: $1"
	$1
}

if [ "$1" = "-r" ]; then
	runcmd "docker rmi ft2-buildtest"
	runcmd "docker build --tag=ft2-buildtest --rm --force-rm $(pwd)/build-test-docker/" || exit
fi

runcmd "docker run --rm -it -v ${_CACHE_DIR}/:/root/.m2/ ft2-buildtest"
