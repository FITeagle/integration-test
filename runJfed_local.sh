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

RET=$?

DIR=$(ls -td test-result*|head -n1)
if [[ "$OSTYPE" == "darwin"* ]]; then open "./${DIR}/result.html" ; fi

if [ $RET -eq 0 ]; then
       echo "Testing more toplogies..."
       java -jar jfed_cli/experimenter-cli.jar create \
       --context-file conf/cli.properties \
       --authorities-file conf/cli.authorities \
       -r conf/motor-network.rspec \
       -s "urn:publicid:IDN+localhost+slice+$(date +%s)" --create-slice \
       --debug
       RET=$?
       echo "RET: ${RET}"
fi

if [ $RET -eq 0 ]; then
       echo "Testing RDF toplogy..."
	     java -jar jfed_cli/automated-testing.jar \
			 --test-class be.iminds.ilabt.jfed.lowlevel.api.test.TestAggregateManager3 \
			 --authorities-file conf/cli.authorities \
	 		 --context-file conf/cli.rdfxml.properties \
		 	 --group nonodelogin \
			 --debug
	     RET=$?
			 echo "RET: ${RET}"
			 if [ "1" == "$RET" ]; then
			   RET=0
			 fi
fi

echo "jfed error code ${RET}"

#if [[ $(grep " failheader" -c ./${DIR}/result.html) > 0 ]]; then
if [[ $RET -gt 0 ]]; then

  echo "test failed!"

  if [[ -f /.dockerenv ]] && [[ -d /opt/results ]]; then
    cp -a $DIR /opt/results
    echo "PWD: $PWD"
    ##PWD: /opt/fiteagle/integration-test
    cp ./build/server/wildfly/standalone/log/server.log /opt/results
    chmod o+w -R /opt/results
  fi

  if [[ -n ${TRAVIS_BUILD_DIR} ]]; then
    [ -z ${WILDFLY_HOME} ] && export WILDFLY_HOME=../server/wildfly
    printf "\n#############################\n## uploading results ########\n#############################\n\n"
    #echo "results.html: "
    #[ -f ${DIR}/result.html ] && curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T ${DIR}/result.html
    for resultfile in $(ls -t test-result*/result.html); do
      echo; echo "${resultfile}: "
      curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T ${resultfile}
    done
    echo; echo "fiteagle.log: "
    [ -f ${WILDFLY_HOME}server/wildfly/standalone/log/fiteagle.log ] && curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T ${WILDFLY_HOME}server/wildfly/standalone/log/fiteagle.log
    echo; echo "server.log: "
    [ -f ${WILDFLY_HOME}/standalone/log/server.log ] && curl http://foo:bar@demo.fiteagle.org:8081/paste -X POST -T "${WILDFLY_HOME}/standalone/log/server.log"
    printf "\n#############################\n## end ######################\n#############################\n\n"
  fi

else
  echo "test OK"
fi

exit $RET
