#!/usr/local/bin/python
import logging, sys, argparse

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
  cli_parser.add_argument('--bbsql', type=int, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbauth', type=int, help='To include or not the bb-services.log')
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
  else:
    readVars(args.file)


# Read the vars from the file
def readVars(filename):
  print filename

# Call the function get_args to define all the arguments
get_args()
