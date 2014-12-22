#!/bin/sh
#!/usr/bin/env expect

#global variables
vDATE=`date +"%Y-%m-%d"`
vEXT='.txt'
vEXT2='.gz'
vDATE2=`date +"%Y%m%d"`

# get what app we are on
vNAME=`hostname`
vAPPS=${vNAME: -5}

#tomcat
vTomcatACCESSFN='bb-access-log.'
vTomcatDIR='/usr/local/blackboard/logs/tomcat/'
vTAFile=$vTomcatDIR$vTomcatACCESSFN$vDATE$vEXT
vTTAFile=$vTomcatDIR'tomcat_access_log-'$vDATE'-'$vAPPS$vEXT2

vTomcatSTDFN='stdout-stderr-'
vTSTDNFile=$vTomcatDIR$vTomcatSTDFN$vDATE2'.log'
vTTSTDNFile=$vTomcatDIR'tomcat_stdout_stderr-'$vDATE'-'$vAPPS$vEXT2

#apache
vApacheFN='access_log'
vApacheDIR='/usr/local/blackboard/logs/httpd/'
vAFile=$vApacheDIR$vApacheFN
vAAFile=$vApacheDIR'apache_access_log-'$vDATE'-'$vAPPS$vEXT2

#blackboard
vBBFN='bb-services-log.txt'
vBBDIR='/usr/local/blackboard/logs/'
vBFile=$vBBDIR$vBBFN
vBBFile=$vBBDIR'bb-services-log-'$vDATE'-'$vAPPS$vEXT2

# SFTP INFORMATION
vHOST='hostname'
vUSER='username'
vPORT='-oPort=10022' #default port is 22

#start logging
echo "========================================="
echo "start of today upload at " `date`
echo "========================================="

# gzip files
echo "gzipping ..."
echo "gzip -c $vTAFile > $vTTAFile"
gzip -c $vTAFile > $vTTAFile

echo "gzip -c $vTSTDNFile > $vTTSTDNFile"
gzip -c $vTSTDNFile > $vTTSTDNFile

echo "gzip -c $vAFile > $vAAFile"
gzip -c $vAFile > $vAAFile

echo "gzip -c $vBFile > $vBBFile"
gzip -c $vBFile > $vBBFile


# SFTP Connection
echo "connecting to sftp..."
sftp $vPORT $vUSER@$vHOST << END_SCRIPT
# change directory to in
cd in
# upload tomcat access log
put $vTTAFile
#upload tomcat std error logs
put $vTTSTDNFile
#upload apache access log
put $vAAFile
# upload file from bb-service.log
put $vBBFile
#quit connection
quit

END_SCRIPT
#remove the newly created gz files to not pile up
echo "removing gzipped files ..."
echo "rm -rf $vTTAFile"
rm -rf $vTTAFile

echo "rm -rf $vTTSTDNFile"
rm -rf $vTTSTDNFile

echo "rm -rf $vAAFile"
rm -rf $vAAFile

echo "rm -rf $vBBFile"
rm -rf $vBBFile
echo "========================================="
echo "end of today upload at " `date`
echo "========================================="
#end
exit 0
