#!/bin/bash

# Daemon that automatically runs every benchmark config files that is dropped into the local/input

exec ssh-agent bash
ssh-add
./run.sh & > /dev/null 2> local/errorLog.txt

