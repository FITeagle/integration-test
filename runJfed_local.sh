#!/usr/bin/env bash

_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${_DIR}

#_VERSION="newest-dev-release"
_VERSION="5.4-dev/r2339"
_URL="http://jfed.iminds.be/releases/${_VERSION}/jar/jfed_cli.tar.gz"
_PATH="jfed_cli"

if [ ! -d "${_PATH}" ]; then 
  echo "downloading $_URL"
  curl -L "${_URL}" | tar -zx
fi

java \
  -jar "${_PATH}/automated-testing.jar" \
  -c be.iminds.ilabt.jfed.lowlevel.api.test.TestAggregateManager3 \
  --authorities-file conf/cli.authorities \
  --debug \
   -p conf/cli.properties \
  --group createsliver
#  --group nonodelogin

RET=$?
echo "jfed error code ${RET}"

DIR=$(ls -td test-result*|head -n1)
if [[ $(grep " failheader" -c ./${DIR}/result.html) > 0 ]]; then
  echo "test failed!"
  #cat ./${DIR}/result.html
else
  echo "test OK"
fi
[[ "$OSTYPE" == "darwin"* ]] && open "./${DIR}/result.html"
exit $RET
