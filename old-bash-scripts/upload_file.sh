#!/bin/sh
#!/usr/bin/env expect

#global variables
vDATE=`date +"%Y-%m-%d"`
vEXT='.txt'
vDATE2=`date +"%Y%m%d"`
vBBHOME="/usr/local/blackboard/"
vBBLOGS="${vBBHOME}/logs"
vPORT=10022

# SFTP INFORMATION
# define your server and your username
vHOST='server'
vUSER='user'

# get what app we are on
vNAME=`hostname`
vAPPS=${vNAME: -5}

#tomcat
vTomcatACCESSFN='bb-access-log.'
vTomcatDIR='${vBBLOGS}/tomcat'
vTAFile=$vTomcatACCESSFN$vDATE$vEXT
vTTAFile='tomcat_access_log-'$vDATE'-'$vAPPS$vEXT

vTomcatSTDFN='stdout-stderr-'
vTSTDNFile=$vTomcatSTDFN$vDATE2'.log'
vTTSTDNFile='tomcat_stdout_stderr-'$vDATE'-'$vAPPS$vEXT

#apache
vApacheFN='access_log'
vApacheDIR='${vBBLOGS}/httpd'
vAFile='apache_access_log-'$vDATE'-'$vAPPS$vEXT

#blackboard
vBBFN='bb-services-log.${vEXT}'
vBBDIR='${vBBLOGS}'
vBFile='bb-services-log-'$vDATE'-'$vAPPS$vEXT


# SFTP Connection using special port (usually is 22)
# remove the -oPort if you dont know if its using any other port (usually is 22)
sftp -oPort=${vPORT}  $vUSER@$vHOST << END_SCRIPT
# change directory to upload files from tomcat
cd in
lcd $vTomcatDIR
# upload tomcat access log
put $vTAFile $vTTAFile
#upload tomcat std error logs
put $vTSTDNFile $vTTSTDNFile
# change directory to upload files from apache
lcd $vApacheDIR
#upload apache access log
put $vApacheFN $vAFile
# change directory to upload files from blackboard bb-services
lcd $vBBDIR
# upload file from bb-service.log
put $vBBFN $vBFile

quit
END_SCRIPT
exit 0
