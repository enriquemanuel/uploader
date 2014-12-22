''' This Script is going to be used for clients that want to upload files
that are already rotated to the vLOGPATH
 to the SFTP configuration
We are also renaming them.
author: Enrique Valenzuela
email: me@enriquemanuel.me
page: http://enriquemanuel.me
'''


vDATE=`date --date yesterday +"%Y-%m-%d"`
vNAME=`hostname`
vAPPNUM=${vNAME: -5}
vLOGPATH='/usr/local/blackboard/rotatedlogs/tomcat'

# SFTP variables
vHOST='server.name'
vUSER='username'
vSFTPPORT='22'
vSFTPATH='path/'
'''
# get file or files from yesterday (the cron is run the next day)
# our rotated logs have the following format:
#tomcat.bb-access-log.2014-05-21.txt.20140521.0207.gz
#tomcat.bb-access-log.2014-05-21.txt.20140522.0203.gz
for that reason we get them by date before the .txt
since one log can be rotated in more than 1 file.
'''

# we found the files and store in this array
cd $vLOGPATH
vFILES=(`find . -type f -name '*'$vDATE'*'`)


# File rename Configuration and execution
counter=0
for file in ${vFILES[*]}; do
	let counter=counter+1
	#renaming the file to what we want
	vNEWFILENAME='tomcat_accesslog_filenum'$counter'-'$vDATE'-'$vAPPNUM'.txt.gz'
	#connecting to SFTP
	sftp -oPort=$vSFTPPORT $vUSER@$vHOST << EOF
	#navigating to the desired path
	cd $vSFTPATH
	#going to our local path
	lcd $vLOGPATH
	#uploading the file
	put $file $vNEWFILENAME
	#closing the connection
	exit
#EOF needs to *not* have any white spaces or tabs before or after it
#closing the sftp automation
#we cycle if there are more files in the array
EOF
#close the for loop
done
#exit the script
exit 0
