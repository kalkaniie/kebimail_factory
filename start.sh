#!/bin/sh
#
## 수정일: 2004/06/25
#
# KM 3.0의 기본 설치 위치

# 기본 설치 위치
BASEDIR=/usr/local/kebi
BINDIR=${BASEDIR}/kebimail_factory
PID=${BINDIR}/kebimail_factory.pid

JARFILE=kebimail_factory.jar

# 실행 권한 검사
CID=`id`
RID=`id kebi`

#if [ "${CID}" != "${RID}" ]
#then
#	echo "kebi로 실행해야 합니다."
#	exit 1
#fi

LOCALE_SET() {
	# locale 한글로 전환
	FINDLOCALE="ko
korean
ko_KR
ko_KR.eucKR
ko_KR.euckr"
	
	for i in ${FINDLOCALE}
	do
		GET_LOCALE=`locale -a | grep "^${i}$"`
		if [ "${GET_LOCALE}" != "" ]
		then
			echo "LOCALE: ${GET_LOCALE}";
			LANG=${GET_LOCALE}
			export LANG
			break
		fi
	done
}

CHECK_PID() {
	GET_PID=$1
	GET_NAME=$2
	GET_PARAM=$3

	# 실행중인지 검사
	if [ -f ${GET_PID} ]
	then
		# 저장된 PID 번호
		SAVED_PID=`cat ${GET_PID}`
	
		# 현재 ps 상태에서
		# 저장된 PID 값을 찾아보고
		# java 프로세스이며 ppid가 1인 경우인지 검사
		# (ppid: 1 이 아닌경우는 child thread이므로 메인 프로그램이 아님)
	
		REAL_PID=`ps -ef |\
			grep 'java' |\
			awk '{if ($3 == 1 && $2 == '${SAVED_PID}') {print $2}}'\
			`
	
		# 같은 프로세스 id 인지 검사
		if [ "${SAVED_PID}" != "${REAL_PID}" ]
		then
			echo "<${SAVED_PID}> IS NOT ${GET_NAME}(?)"
			echo "RM ${GET_PID}"
			# 쓰레기 파일 삭제
			chmod 755 ${GET_PID}
			/bin/rm -f ${GET_PID}
		else
			# 작동중이므로 start.sh 종료
			echo "${GET_NAME} RUNNING!"
			return
		fi
	fi
	LOCALE_SET
	${GET_PARAM} &
	#${GET_PARAM} &
	echo $! > ${GET_PID}
	chmod 444 ${GET_PID}
	echo "${GET_NAME} START"
}

CHECK_PID ${PID} "DISKMANAGER" "java -server -Dcom.nara.jdf.config.file=conf/factory.properties -classpath lib/${JARFILE}:lib/nara_jdf.jar:lib/ojdbc14.jar:lib/mysql-connector-java-3.1.8-bin.jar:lib/mail.jar:lib/activation.jar:lib/naramail.jar com.nara.kebi.factory.Factory"
