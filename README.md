Uploader
=========
Due to increasingly clients requesting to upload logs, I decided to implement a new and improved script to fully automated and send the logs as needed.

At this time, the script is very smart to upload the files needed, and the implementation is done in two ways.
* You can input the options in the same line as the script is run
* You can store the variables of the options in a file and invoke the script with a file option.

Help?
===========
The script has a help option that you can invoke and learn how to use it as needed. this can be done with the -h option or with --help.

To note that -d (–debug) or -l (--log-file) have been implemented at this stage.

    # ./script.py --help
    usage: script.py [-h] [-d] [-l LOGFILE] [-V] {file,cli} ...
    Upload Blackboard Logs to SFTP
    positional arguments:
    {file,cli}            Select which Option File or CLI in order to do it
                        correctly
    file                Define the File that we are reading the variables
    cli                 Define the arguments in the same line of execution
    optional arguments:
    -h, --help            show this help message and exit
    -d, --debug           Enable debug output
    -l LOGFILE, --log-file LOGFILE
                        File to log to (default = stdout)
    -V, --version         show program's version number and exit

If you require further help of a command, you can perform it as is:

    # ./script.py file --help
    usage: script.py file [-h] -f FILE
    optional arguments:
      -h, --help            show this help message and exit
      -f FILE, --file FILE  Source File

or

    # ./script.py cli --help
    usage: script.py cli [-h] --sftp SFTP --user USER [--id ID] [--port PORT]
                     [--path PATH] [--bbservices BBSERVICES] [--bbsql BBSQL]
                     [--bbauth BBAUTH] [--bbsessions BBSESSIONS]
                     [--bbemail BBEMAIL] [--tomcataccess TOMCATACCESS]
                     [--tomcatstd TOMCATSTD]
    optional arguments:
    -h, --help            show this help message and exit
    --sftp SFTP           SFTP server to connect to.
    --user USER           User used to connect to SFTP.
    --id ID               ID file to be used with path eg:
                          /Users/userid/.ssh/server_rsa (default is
                          ~/.ssh/id_rsa)
    --port PORT           Port to connect to SFTP (default is 22)
    --path PATH           Path to drop the logs (default is /)
    --bbservices BBSERVICES
                          To include or not the bb-services.log
    --bbsql BBSQL         To include or not the bb-services.log
    --bbauth BBAUTH       To include or not the bb-services.log
    --bbsessions BBSESSIONS
                          To include or not the bb-services.log
    --bbemail BBEMAIL     To include or not the bb-services.log
    --tomcataccess TOMCATACCESS
                          To include or not the bb-services.log
    --tomcatstd TOMCATSTD
                          To include or not the bb-services.log

The idea
============
The idea behind this script is to automatically connect to the server (no password interaction), so it connects uploads the files and disconnect.

This is done via Public / Private keys which needs to be generated from the Blackboard side. 
If you don't know how to perform this, please read any of the below articles:
* How to create Public and Private keys: https://help.github.com/articles/generating-ssh-keys
* If they don't work, I would suggest you troubleshoot this: http://inderpreetsingh.com/2011/08/04/ssh-privatepublic-key-auth-not-working/

How to execute it?
=================
After you have installed and configured the Public and Private keys, my recommendation are the following:

1. Create a directory under $BBHOME/content/vi/<schema>/plugins directory. In my case I like to name it the same log_uploader
2. In the same directory, I copy the files from the tempstore and the keys that were just created.
3. Create / Modify the vars.txt file or whatever you want to call it that it will contain the options for the execution.

After you have this set up, you can review the vars.txt file and make the require modifications to input the logs that the client wants as well as where the Public Key is located. If none is given, it will default to the systems default, the same applies for the port (22).

How does it work?
=================
* What I found that was needed, was to upload the log from "yesterday" since the logs are rotated at off hours depending on the server, so we are actually uploading files that were completed the day before. For that reason you can schedule the CRON at early hours or late hours depending on your needs. My recommendation is at late hours, that way you are not grabbing a file that was rotated or is in rotation process.
* The Script will create a temporary location with all the logs that you requested that is under /tmp/uploader and gzip the logs accordingly.
* After the uploading occurred, it will delete the files and the temporary location.
* The Script will output to the screen. Output to the log has not been created yet, but is in process.
* There is a batchfile that was created. This is for uploading purposes, and should not be touched nor modified.

Example of Use
===============

At this time, this has been configured on University of XXXX, where you can see the cron with the following information:

#LOG uploader  
0 2 * * * /usr/local/blackboard/content/vi/bb_bb60/plugins/log_uploader/script.py file -f /usr/local/blackboard/content/vi/bb_bb60/plugins/log_uploader/vars.txt >> /usr/local/blackboard/content/vi/bb_bb60/plugins/log_uploader/uploader.log

Please look that it contains a full path for safety measures. Also it is run as root and it should be in the cron of root. This is because of permissions on the /tmp location.

Logging
==========

Like I mentioned before, there is no logging implemented in the script, but it will  output to the screen and based on the >> to a log as you can see in the cron above.

An example of the log is:

    sftp> put /tmp/uploader/*
    Uploading /tmp/uploader/app06-bb-access-log.2014-12-09.gz to /home/bbdata/app06-bb-access-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-bb-authentication-log.2014-12-09.gz to /home/bbdata/app06-bb-authentication-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-bb-email-log.2014-12-09.gz to /home/bbdata/app06-bb-email-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-bb-services-log.2014-12-09.gz to /home/bbdata/app06-bb-services-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-bb-session-log.2014-12-09.gz to /home/bbdata/app06-bb-session-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-bb-sqlerror-log.2014-12-09.gz to /home/bbdata/app06-bb-sqlerror-log.2014-12-09.gz
    Uploading /tmp/uploader/app06-stdout-stderr-20141209.gz to /home/bbdata/app06-stdout-stderr-20141209.gz
    sftp> quit
    removing temp local files
    ====================================================
    process completed at 2014-12-10 11:14:24.730874 for apcprd-100501-9576-app06
    ====================================================

New features?
==============

If you need any additional features, please let me know. At this time, the server should work for most cases and it should be fairly simple to implement without any problem.

Requirements
=============

The main requirements at this time are:
* Create the Public and Private key
* Client Server needs to be UNIX - no windows!
* Client Server needs to have the Private key installed with correct permissions
