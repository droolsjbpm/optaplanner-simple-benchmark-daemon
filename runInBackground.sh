#!/bin/bash

# Daemon that automatically runs every benchmark config files that is dropped into the local/input

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi
./run.sh & > /dev/null 2> local/errorLog.txt

