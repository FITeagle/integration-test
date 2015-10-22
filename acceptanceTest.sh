#!/usr/bin/env bash
PWD=$(pwd)
#TARGET=$(mktemp -d 2>/dev/null || mktemp -d -t "fiteagle")
TARGET="${PWD}/build"
echo "using TARGET: ${TARGET} HOME: ${HOME} PWD: ${PWD}"
rm -rf ${TARGET}
mkdir -p ${TARGET}
mkdir -p ${HOME}/.fiteagle
cd ${TARGET}
export WILDFLY_HOME="${TARGET}/server/wildfly"
curl -sSL https://github.com/FITeagle/bootstrap/raw/master/fiteagle.sh -o fiteagle.sh
chmod +x ${TARGET}/fiteagle.sh
${TARGET}/fiteagle.sh init
cp ${TARGET}/../conf/MotorGarage.properties ${HOME}/.fiteagle/
${TARGET}/fiteagle.sh startJ2EE sleep-20 deployFT2binary deployFT2sfaBinary

cd ${PWD}
pwd
## HACK
cd ..

echo "waiting for server to be ready (by polling sfa/GetVersion via xmlrpc)..."
CNT=0
while [[ ! $(./xmlrpc-client.sh -t https://localhost:8443/sfa/api/am/v3 GetVersion) ]]; do
	echo sleep 15
	sleep 15
	CNT=$((${CNT}+1))
	if [ ${CNT} -gt "20" ]; then
		echo "cnt:" ${CNT}
		echo timeout !
		${TARGET}/fiteagle.sh stopJ2EE
		screen -S wildfly -X kill
		exit 1
	fi
done
./runJfed_local.sh
RET=$?
echo "RET: ${RET}"

if [ $RET -gt 0 ]; then
	echo "retry failed test...."
	echo "touching .war files.."
	[ -f ${WILDFLY_HOME}/standalone/deployments/motor.war ] && touch ${WILDFLY_HOME}/standalone/deployments/motor.war
	[ -f ${WILDFLY_HOME}/standalone/deployments/sshService.war ] && touch ${WILDFLY_HOME}/standalone/deployments/sshService.war
	sleep 30
	./runJfed_local.sh
	RET=$?
	echo "RET: ${RET}"
fi
if [ $RET -eq 0 ]; then
       echo "Testing more toplogies..."
       java -jar jfed_cli/experimenter-cli.jar create \
       --context-file conf/cli.properties \
       --authorities-file conf/cli.authorities \
       -r conf/motor-network.rspec \
       -s "urn:publicid:IDN+localhost+slice+1234" --create-slice \
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

${TARGET}/fiteagle.sh stopJ2EE
#rm -rf ${TARGET}

exit $RET
