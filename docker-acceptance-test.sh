#!/bin/sh

echo "docker acceptence tests..."

runcmd() {
	echo "cmd: ${1}"
	$1
}

if [ "$1" = "-r" ]; then
	runcmd "docker tag ft2-actest:latest ft2-actest:current"
	runcmd "docker rmi ft2-actest:latest"
	runcmd "docker build --tag=ft2-actest --rm --force-rm ." || exit
	runcmd "docker rmi ft2-actest:current"
fi

runcmd "docker run -v ${PWD}/results:/opt/results --rm -it ft2-actest"
