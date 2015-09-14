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
${TARGET}/fiteagle.sh deployFT2binary deployFT2sfaBinary
curl -sSL https://github.com/FITeagle/core/raw/master/federationManager/src/main/resources/ontologies/defaultFederation.ttl -o ${HOME}/.fiteagle/Federation.ttl
cp ${TARGET}/../conf/MotorGarage.properties ${HOME}/.fiteagle/
${TARGET}/fiteagle.sh startJ2EE

cd ${PWD}
pwd
## HACK
cd ..

echo "waiting for server to be ready..."
CNT=0
while [[ ! $(./xmlrpc-client.sh -t https://localhost:8443/sfa/api/am/v3 GetVersion) ]]; do
	echo sleep 15
	sleep 15
	CNT=$((${CNT}+1))
	if [ ${CNT} -gt "20" ]; then
		echo "cnt:" ${CNT}
		echo timeout !
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
	[ -f ${WILDFLY_HOME}/deployments/motor.war ] && touch ${WILDFLY_HOME}/deployments/motor.war
	[ -f ${WILDFLY_HOME}/deployments/sshService.war ] && touch ${WILDFLY_HOME}/deployments/sshService.war
	sleep 30
	./runJfed_local.sh
	RET=$?
	echo "RET: ${RET}"
fi

${TARGET}/fiteagle.sh stopJ2EE
#rm -rf ${TARGET}

exit $RET
