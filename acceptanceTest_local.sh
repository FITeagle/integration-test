#!/usr/bin/env bash
PWD=$(pwd)


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
	sleep 10
	./runJfed_local.sh
	RET=$?
	echo "RET: ${RET}"
fi


exit $RET