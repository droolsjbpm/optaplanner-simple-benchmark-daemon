#!/bin/bash

# Daemon that automatically runs every benchmark config files that is dropped into the local/input

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi
if [ `ps aux | grep "run.sh" | grep -v "grep" | wc -l` ]; then
  echo
  echo "ERROR: There is already a process called run.sh running. Kill it first."
  echo
  ps aux | grep "run.sh" | grep -v "grep"
  exit 1
fi
(./run.sh &) > /dev/null 2> local/errorLog.txt
