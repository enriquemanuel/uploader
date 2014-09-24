#!/usr/local/bin/python
import logging, sys, argparse


parser = argparse.ArgumentParser(description='Upload Blackboard Logs to SFTP')
parser.add_argument('-f', '--file', type=str, nargs=1, help='The file to read the configuration if we are using file.')

args = parser.parse_args()
print args.file
