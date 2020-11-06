#!/bin/sh
#
## 수정일: 2004/08/17
#          함수로 검사
## 수정일: 2004/06/23
#
# 파일에 저장된 diskmanager의 pid값을 불러와 stop

# KM 3.0의 기본 설치 위치
BASEDIR=/usr/local/kebi
BINDIR=${BASEDIR}/kebimail_factory
PIDFILE=${BINDIR}/kebimail_factory.pid

CHECK_PID() {
	GET_PID=$1
	GET_NAME=$2
	GET_PARAM=$3

	if [ -f ${GET_PID} ]
	then
		# 저장된 PID 값
		SAVED_PID=`cat ${GET_PID}`
	
		# 저장된 값으로 ps에서 찾아낸 값과 다시 비교
		REAL_PID=`ps -ef |\
			grep 'java' |\
			awk '{if ($3 == 1 && $2 == '${SAVED_PID}') {print $2}}'\
			`
	
		# 저장된 값과 실제 pid가 같은지 검사
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

