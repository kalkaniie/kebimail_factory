#!/bin/sh
#
## ������: 2004/06/25
#
# KM 3.0�� �⺻ ��ġ ��ġ

# �⺻ ��ġ ��ġ
BASEDIR=/usr/local/kebi
BINDIR=${BASEDIR}/kebimail_factory
PID=${BINDIR}/kebimail_factory.pid

JARFILE=kebimail_factory.jar

# ���� ���� �˻�
CID=`id`
RID=`id kebi`

#if [ "${CID}" != "${RID}" ]
#then
#	echo "kebi�� �����ؾ� �մϴ�."
#	exit 1
#fi

LOCALE_SET() {
	# locale �ѱ۷� ��ȯ
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

	# ���������� �˻�
	if [ -f ${GET_PID} ]
	then
		# ����� PID ��ȣ
		SAVED_PID=`cat ${GET_PID}`
	
		# ���� ps ���¿���
		# ����� PID ���� ã�ƺ���
		# java ���μ����̸� ppid�� 1�� ������� �˻�
		# (ppid: 1 �� �ƴѰ��� child thread�̹Ƿ� ���� ���α׷��� �ƴ�)
	
		REAL_PID=`ps -ef |\
			grep 'java' |\
			awk '{if ($3 == 1 && $2 == '${SAVED_PID}') {print $2}}'\
			`
	
		# ���� ���μ��� id ���� �˻�
		if [ "${SAVED_PID}" != "${REAL_PID}" ]
		then
			echo "<${SAVED_PID}> IS NOT ${GET_NAME}(?)"
			echo "RM ${GET_PID}"
			# ������ ���� ����
			chmod 755 ${GET_PID}
			/bin/rm -f ${GET_PID}
		else
			# �۵����̹Ƿ� start.sh ����
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
