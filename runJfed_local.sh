#!/usr/bin/env bash

_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${_DIR}

_VERSION="233"
_URL="http://jfed.iminds.be/releases/develop/${_VERSION}/jar/jfed_cli.tar.gz"
_PATH="jfed_cli"

if [ ! -d "${_PATH}" ]; then
  echo "downloading $_URL"
  curl -L "${_URL}" | tar -zx
fi

java \
  -jar "${_PATH}/automated-testing.jar" \
  --test-class be.iminds.ilabt.jfed.lowlevel.api.test.TestAggregateManager3 \
  --authorities-file conf/cli.authorities \
  --debug \
  --context-file conf/cli.properties \
  --group nonodelogin
#createsliver

RET=$?
echo "jfed error code ${RET}"

DIR=$(ls -td test-result*|head -n1)
if [[ $(grep " failheader" -c ./${DIR}/result.html) > 0 ]]; then
  
  echo "test failed!"

  if [[ -f /.dockerenv ]] && [[ -d /opt/results ]]; then
    cp -a $DIR /opt/results
    echo "PWD: $PWD"
    ##PWD: /opt/fiteagle/integration-test
    cp ./build/server/wildfly/standalone/log/server.log /opt/results
    chmod o+w -R /opt/results
  fi

  if [[ -n ${TRAVIS_BUILD_DIR} ]]; then
    printf "\n#############################\n## uploading results ########\n#############################\n\n"
    echo "results.html: "
    curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T ${DIR}/result.html
    echo ""
    echo "server.log: "
    curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T "${WILDFLY_HOME}/standalone/log/server.log"
    printf "\n#############################\n## end ######################\n#############################\n\n"
  fi

else
  echo "test OK"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then open "./${DIR}/result.html" ; fi

exit $RET
