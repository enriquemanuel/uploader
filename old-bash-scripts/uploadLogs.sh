#!/bin/bash
# Upload logs to client SFTP
# Author: Enrique Valenzuela <enrique.valenzuela@blackboard.com>
# Version: 1.0
# 		- Improved version that contains parameters
# 		- Debug (verbosity still not enabled and functioning)

###### Constants
BBHOMELOGS='/usr/local/blackboard/logs/'
HOSTNAME=`hostname`
APPNUM=${HOSTNAME: -5}
GZEXT='.gz'
DATE1=`date +"%Y-%m-%d"`
DATE2=`date +"%Y%m%d"`


##### File Names
A='bb-services-log.txt'
B='bb-sqlerror-log.txt'
C='bb-authentication-log.txt'
D='bb-session-log.txt'
E='bb-email-log.txt'
F='access_log'
G='bb-access-log.'$DATE1'.txt'
I='stdout-stderr-'$DATE2'.log'

##### Functions
function usage()
{
	cat << EOF
usage: $0 options

This script uploads the different logs depending on your selection to client SFTP

OPTIONS:
   -h 			Show this message
   -a			Include bb-services log - values{y,yes,no,n}
   -b			Include bb-sql log - values{y,yes,no,n}
   -c			Include bb-authentication log - values{y,yes,no,n}
   -d 			Include bb-sessions log - values{y,yes,no,n}
   -e			Include bb-email log - values{y,yes,no,n}
   -f			Include httpd/access log - values{y,yes,no,n}
   -g			Include tomcat/access log - values{y,yes,no,n}
   -i			Include tomcat/stderror log - values{y,yes,no,n}
   -j 			User to connect to SFTP - values{user}
   -k 			Host Server to connect to SFTP - values{somes.server.edu} 
   -l 			Port to connect to the SFTP - values{2222, 3182} - DEFAULT=22
   -m			Path to place the logs - values (/home/bblogs or /logs) - DEFAULT=/
   -n			Identity File to connect Passwordless - example: /.ssh/id_rsa
   

EOF
}

function validate()
{
	echo "variables"
	echo $BBSERVICES
	echo $BBSQL
	echo $BBAUTHENTICATION
	echo $BBSESSIONS
	echo $BBEMAIL
	echo $BBHTTPDACCESS
	echo $BBTOMCATACCESS
	echo $BBTOMCATSTD
	echo $USERSFTP
	echo $HOST
	echo $PORT
	echo $SFTPPATH
}

function checksftp()
{
	if [ "${USERSFTP}" == "" ]; then
		echo "Required field: We need the User to connect to the SFTP"
		INCOMPLETE=1
	fi
	if [ "${HOST}" == "" ]; then
		echo "Required field: We need the Hostname to connect to the SFTP"
		INCOMPLETE=1
	fi
	if [ "${PORT}" == "" ]; then
		PORT=22
	fi
	if [ "${SFTPPATH}" == "" ]; then
		SFTPPATH=/
	fi
	if [ "${IDENTITY}" == "" ]; then
		echo "Required field: Identity file to be able to connect passwordless"
		INCOMPLETE=1
	fi
	iscomplete
}


function iscomplete()
{
	if [[ $INCOMPLETE = 1 ]]; then
		exit 1
	else
		echo $HOST
		echo $USERSFTP
		#validate
		gziplogs
	fi
}


function gziplogs()
{
	if [ "${BBSERVICES}" == "y" ] || [ "${BBSERVICES}" == "yes" ]; then
		echo $BBHOMELOGS$A
		gzip -c $BBHOMELOGS$A > /tmp/$APPNUM-$A-$DATE2$GZEXT
	fi
	if [ "${BBSQL}" == "y" ] || [ "${BBSQL}" == "yes" ]; then
		echo $BBHOMELOGS$B
		gzip -c $BBHOMELOGS$B > /tmp/$APPNUM-$B-$DATE2$GZEXT
	fi
	if [ "${BBAUTHENTICATION}" == "y" ] || [ "${BBAUTHENTICATION}" == "yes" ]; then
		echo $BBHOMELOGS$C
		gzip -c $BBHOMELOGS$C > /tmp/$APPNUM-$C-$DATE2$GZEXT
	fi
	if [ "${BBSESSIONS}" == "y" ] || [ "${BBSESSIONS}" == "yes" ]; then
		echo $BBHOMELOGS$D
		gzip -c $BBHOMELOGS$D > /tmp/$APPNUM-$D-$DATE2$GZEXT
	fi
	if [ "${BBEMAIL}" == "y" ] || [ "${BBEMAIL}" == "yes" ]; then
		echo $BBHOMELOGS$E
		gzip -c $BBHOMELOGS$E > /tmp/$APPNUM-$E-$DATE2$GZEXT
	fi
	if [ "${BBHTTPDACCESS}" == "y" ] || [ "${BBHTTPDACCESS}" == "yes" ]; then
		echo $BBHOMELOGS'httpd'/$F
		gzip -c $BBHOMELOGShttpd/$F > /tmp/$APPNUM-$F-$DATE2$GZEXT
	fi
	if [ "${BBTOMCATACCESS}" == "y" ] || [ "${BBTOMCATACCESS}" == "yes" ]; then
		echo $BBHOMELOGS'tomcat'/$G
		gzip -c $BBHOMELOGS'tomcat'/$G > /tmp/$APPNUM-$G-$DATE2$GZEXT
	fi	
	if [ "${BBTOMCATSTD}" == "y" ] || [ "${BBTOMCATSTD}" == "yes" ]; then
		echo $BBHOMELOGS'tomcat'/$I
		gzip -c $BBHOMELOGS'tomcat'/$I > /tmp/$APPNUM-$I-$DATE2$GZEXT
	fi
	#call next function
	connect
}

function connect()
{
	FILES=(`ls /tmp/$APPNUM*-$DATE2$GZEXT`)
	#echo "sftp -oIdentityFile=$IDENTITY -oPort=$PORT $USERSFTP@$HOST"
	for file in ${FILES[*]}; do
	sftp -oPort=$PORT -oIdentityFile=$IDENTITY $USERSFTP@$HOST << EOF
	cd $SFTPPATH
	lcd /tmp
	put $file
	exit
EOF
done
deletetmpfiles
}

function deletetmpfiles()
{
	rm -rf /tmp/$APPNUM*-$DATE2$GZEXT
}

#while getopts “ht:r:p:v” OPTION
while getopts "ha:b:c:d:e:f:g:i:j:k:l:m:n:v" opts 
do
	case $opts in
		h) 	usage
			#validate 
			exit 1 ;;
		a) BBSERVICES=${OPTARG}  ;;
		b) BBSQL=${OPTARG}  ;;
		c) BBAUTHENTICATION=${OPTARG}  ;;
		d) BBSESSIONS=${OPTARG}  ;;
		e) BBEMAIL=${OPTARG}  ;;
		f) BBHTTPDACCESS=${OPTARG}  ;;
		g) BBTOMCATACCESS=${OPTARG}  ;;
		i) BBTOMCATSTD=${OPTARG}  ;;
		j) USERSFTP=${OPTARG}  ;;
		k) HOST=${OPTARG}  ;;
		l) PORT=${OPTARG}  ;;
		m) SFTPPATH=${OPTARG}  ;;
		n) IDENTITY=${OPTARG}  ;;
		
	esac
done

checksftp
