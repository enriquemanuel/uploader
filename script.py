#!/usr/local/bin/python
import logging, sys, argparse

def get_args():
  parser = argparse.ArgumentParser(description='Upload Blackboard Logs to SFTP')

  # configuring subparsers for actions
  subparsers = parser.add_subparsers(help='Select which Option File or CLI in order to do it correctly')

  # File Line Argument
  file_parser = subparsers.add_parser('file', help='Define the File that we are reading the variables')
  file_parser.add_argument('-f', '--file', required=True,  help='Source File', type=str)

  # Command Line Arguments
  cli_parser = subparsers.add_parser('cli', help='Define the arguments in the same line of execution')
  cli_parser.add_argument('--sftp',required=True, type=str, help='SFTP server to connect to.')
  cli_parser.add_argument('--user',required=True, type=str, help='User used to connect to SFTP.')
  cli_parser.add_argument('--id', required=True, type=str, help='ID file to be used with path eg: /Users/userid/.ssh/server_rsa')
  cli_parser.add_argument('--port', type=str, help='Port to connect to SFTP, default is 22')
  cli_parser.add_argument('--path', type=str, help='Path to drop the logs, default is /')
  #now the logs
  cli_parser.add_argument('--bbservices', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbsql', type=int, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbauth', type=int, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbsessions', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--bbemail', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--tomcataccess', type=str, help='To include or not the bb-services.log')
  cli_parser.add_argument('--tomcatstd', type=str, help='To include or not the bb-services.log')






  args = parser.parse_args()
  return args

args = get_args()
print args
