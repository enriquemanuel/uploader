#!/usr/local/bin/python # if local
## if in MH Servers #!/mnt/asp/python/bin/python

import logging, sys, argparse, gzip, os, datetime, socket

def get_args():
  # Define the parser
  parser = argparse.ArgumentParser(description='Upload Blackboard Logs to SFTP')
  parser.add_argument('-d', '--debug', required=False, help='Enable debug output', action='store_true')
  parser.add_argument('-l', '--log-file', nargs=1, required=False, help='File to log to (default = stdout)', dest='logfile', type=str)
  parser.add_argument('-V', '--version', action='version', version="%(prog)s (version 0.1)")

  # Configuring subparsers for actions
  subparsers = parser.add_subparsers(help='Select which Option File or CLI in order to do it correctly')

  # File Line Argument
  file_parser = subparsers.add_parser('file', help='Define the File that we are reading the variables')
  file_parser.add_argument('-f', '--file', required=True,  help='Source File', type=str)

  # Command Line Arguments
  cli_parser = subparsers.add_parser('cli', help='Define the arguments in the same line of execution')
  cli_parser.add_argument('--sftp',required=True, type=str, help='SFTP server to connect to.')
  cli_parser.add_argument('--user',required=True, type=str, help='User used to connect to SFTP.')
  cli_parser.add_argument('--id', type=str, help='ID file to be used with path eg: /Users/userid/.ssh/server_rsa (default is ~/.ssh/id_rsa)')
  cli_parser.add_argument('--port', type=str, help='Port to connect to SFTP (default is 22)')
  cli_parser.add_argument('--path', type=str, help='Path to drop the logs (default is /)')
  cli_parser.add_argument('--bbservices', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbsql', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbauth', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbsessions', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbemail', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--tomcataccess', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--tomcatstd', type=str, help='To include or not the bb-services.log')

  args = parser.parse_args()

  # Set all the Vars
  return setVars(args)

def setVars(args):

  try:
    args.file
  except AttributeError: # file is not defined, so using CLI
    if args.port is None:
      args.port=22
    if args.path is None:
      args.path='/'
    if args.id is None:
      args.id='~/.ssh/id_rsa'
    findAndCompressLogs(vars(args))
  else:
    readVars(args.file)


# Read the vars from the file
def readVars(filename):
  with open(filename) as f:
    varsdict = {}
    for line in f:
      items = line.split(':', 1)
      varsdict[items[0]] = items[1].rstrip('\n')
  findAndCompressLogs(varsdict)


def findAndCompressLogs(dict):
  # first lets create the temp folder
  tmpFolder = createTmpFolder()
  files=[]

  if dict['bbservices'] == 'Y':
    output = gzipFile(tmpFolder, filenameDict['bbservices'], yesDate2)
    files.append(output)
  if dict['bbsql'] == 'Y':
    output = gzipFile(tmpFolder, filenameDict['bbsql'], yesDate2)
    files.append(output)
  if dict['bbauth'] =='Y' :
    output = gzipFile(tmpFolder, filenameDict['bbauth'], yesDate2)
    files.append(output)
  if dict['bbsessions'] =='Y':
    output = gzipFile(tmpFolder, filenameDict['bbsessions'], yesDate2)
    files.append(output)
  if dict['bbemail'] == 'Y':
    output = gzipFile(tmpFolder, filenameDict['bbemail'], yesDate2)
    files.append(output)
  if dict['tomcataccess'] == 'Y':
    output = gzipFile(tmpFolder, filenameDict['tomcataccess'], yesDate2)
    files.append(output)
  if dict['tomcatstd'] == 'Y':
    output = gzipFile(tmpFolder, filenameDict['tomcatstd'], yesDate1)
    files.append(output)


  uploadFiles(files, dict)


def createTmpFolder():
  if not os.path.exists('/tmp/uploader'):
    os.makedirs('/tmp/uploader')
    folder='/tmp/uploader/'
    return folder
  else:
    return False


def gzipFile(tmpFolder, inputFilename, date):
  bbLogsPath='/usr/local/blackboard/logs/'
  log=""
  if  inputFilename == 'stdout-stderr-':
   # print "inside the if " +inputFilename
    log = inputFilename + date + '.log'
    inputFile=open(bbLogsPath +'tomcat/' +log, 'rb')
  if inputFilename == 'bb-access-log.':
  #  print "inside if "+ inputFilename
    log = inputFilename + date + '.txt'
    inputFile=open(bbLogsPath +'tomcat/' +log, 'rb')
  elif log == "":
    #print "else " + inputFilename
    log = inputFilename + date + '.txt'
    inputFile=open(bbLogsPath +log, 'rb')

  gzipFile=appnum + '-' + inputFilename + date +'.gz'
  gzippedFile=gzip.open('/tmp/uploader/'+'/'+gzipFile, 'wb')
  gzippedFile.writelines(inputFile)
  gzippedFile.close()
  inputFile.close()
  return gzipFile


def uploadFiles(files,dict):
  print "uploading the folloing files:"
  print files
  os.system("sftp -b /usr/local/blackboard/content/vi/bb_bb60/plugins/log_uploader/batchfile -oPort=" + str(dict['port']) + " -oIdentityFile="+str(dict['id']) + " " +str(dict['user']) + "@" + str(dict['sftp']) + ":" + str(dict['path'] ) )
  #os.system("rsync -azP -e 'ssh -p " + str(dict['port']) + " -i " + str(dict['id']) + "' /tmp/uploader/ " + str(dict['user']) + "@" + str(dict['sftp'])
+ ":" + str(dict['path']))
  # rsync -azP -e 'ssh -p22 -i /tmp/bk/evalenzuela/something_rsa' /tmp/uploader/ ftpuser@104.131.39.131:files/
  print "removing files"
  shutil.rmtree('/tmp/uploader/')


####################
### GLOBAL VARS ####
####################
globalargs ={}
today = datetime.datetime.now()
curDate2 = today.strftime("%Y-%m-%d")

yesterday = datetime.datetime.now() - datetime.timedelta(days = 1)
yesDate1 = yesterday.strftime("%Y%m%d")
yesDate2 = yesterday.strftime("%Y-%m-%d")

hostname = socket.gethostname()
appnum = hostname[-5:]


filenameDict = {'bbservices': 'bb-services-log.',
                'bbsql': 'bb-sqlerror-log.',
                'bbauth': 'bb-authentication-log.',
                'bbsessions': 'bb-session-log.',
                'bbemail': 'bb-email-log.',
                'tomcataccess': 'bb-access-log.',
                'tomcatstd': 'stdout-stderr-' }


# Call the function get_args to define all the arguments
get_args()
