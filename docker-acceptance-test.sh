#!/bin/sh

echo "docker acceptence tests..."

runcmd() {
	echo "cmd: $1"
	$1
}

if [ "$1" = "-r" ]; then
	runcmd "docker rmi ft2-actest"
	runcmd "docker build --tag=ft2-actest --rm ." || exit
fi

runcmd "docker run --rm -it ft2-actest"
