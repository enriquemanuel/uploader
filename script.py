#!/usr/local/bin/python
import logging, sys, argparse


parser = argparse.ArgumentParser(description='Upload Blackboard Logs to SFTP')
parser.add_argument('-f', '--file', type=str, nargs=1, help='The file to read the configuration if we are using file.')
parser.add_argument('-i', '--inline', type=str, nargs=1, help='We are reading the configuration from the input as variables.')
