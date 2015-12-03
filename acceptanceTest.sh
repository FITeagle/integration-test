#!/usr/bin/env bash

fold_begin() {}
	echo "travis_fold:start:${1}"
	if [ -z $2 ]; then 
		echo "${1}: "
	else
		echo "${2}: "
	fi
}

fold_end() {}
	echo "travis_fold:stop:${1}"
}

fold_begin Prepare
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
fold_end Prepare

fold_begin Init
${TARGET}/fiteagle.sh init
cp ${TARGET}/../conf/MotorGarage.properties ${HOME}/.fiteagle/
cp ${TARGET}/../conf/NetworkingAdapter.properties ${HOME}/.fiteagle/
fold_end Init

Fold_begin deploy "deployFT2binary deployFT2sfaBinary"
${TARGET}/fiteagle.sh startJ2EE sleep-20 deployFT2binary deployFT2sfaBinary
Fold_end deploy

Fold_begin test1 "1st jFed test"
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
		Fold_end test1
		exit 1
	fi
done
./runJfed_local.sh
RET=$?
echo "RET: ${RET}"
Fold_end test1

if [ $RET -gt 0 ]; then
	Fold_begin test2 "2nd jFed test"
	echo "retry failed test...."
	echo "touching .war files.."
	[ -f ${WILDFLY_HOME}/standalone/deployments/motor.war ] && touch ${WILDFLY_HOME}/standalone/deployments/motor.war
	[ -f ${WILDFLY_HOME}/standalone/deployments/sshService.war ] && touch ${WILDFLY_HOME}/standalone/deployments/sshService.war
	sleep 30
	./runJfed_local.sh
	RET=$?
	echo "RET: ${RET}"
	Fold_end test2
fi

${TARGET}/fiteagle.sh stopJ2EE
#rm -rf ${TARGET}

exit $RET
