#!/bin/sh
#
## ������: 2004/08/17
#          �Լ��� �˻�
## ������: 2004/06/23
#
# ���Ͽ� ����� diskmanager�� pid���� �ҷ��� stop

# KM 3.0�� �⺻ ��ġ ��ġ
BASEDIR=/usr/local/kebi
BINDIR=${BASEDIR}/kebimail_factory
PIDFILE=${BINDIR}/kebimail_factory.pid

CHECK_PID() {
	GET_PID=$1
	GET_NAME=$2
	GET_PARAM=$3

	if [ -f ${GET_PID} ]
	then
		# ����� PID ��
		SAVED_PID=`cat ${GET_PID}`
	
		# ����� ������ ps���� ã�Ƴ� ���� �ٽ� ��
		REAL_PID=`ps -ef |\
			grep 'java' |\
			awk '{if ($3 == 1 && $2 == '${SAVED_PID}') {print $2}}'\
			`
	
		# ����� ���� ���� pid�� ������ �˻�
		if [ "${SAVED_PID}" = "${REAL_PID}" ]
		then
			if [ "${GET_PARAM}" != "" ]
			then
				${GET_PARAM}
				sleep 2
			fi
			kill ${SAVED_PID} > /dev/null 2>&1
			echo "${GET_NAME} STOP"
		else
			if [ "${REAL_PID}" = "" ]
			then
				echo "${GET_NAME} NOT RUNNING"
			else
				echo "<${SAVED_PID}> IS NOT ${GET_NAME}(?)"
			fi
		fi
	
		chmod 755 ${GET_PID}
		/bin/rm -f ${GET_PID}
	else
		echo "${GET_NAME} NOT RUNNING"
	fi
}

CHECK_PID ${PIDFILE} "DISKMANAGER"

