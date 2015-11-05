#!/bin/bash

# Daemon that automatically runs every benchmark config files that is dropped into the local/input

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi
if [ `ps aux | grep "run.sh" | wc -l` ]; then
  echo "There is already a process called run.sh running. Kill it first."
  exit 1
fi
(./run.sh &) > /dev/null 2> local/errorLog.txt
