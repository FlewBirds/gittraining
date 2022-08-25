#!/bin/bash

# -d : the file type should be directory
# -e : file exits or not
# -f : file exists and it is a regular file (-)
# -r : file exists and has read permission
# -w : file exists and has write permission
# -x : file exists and has execute permission
# -s : file exists and size gt 0

if [ -e /etc/passwd ]
then
	echo "userdatabase file exist"
else
	echo "userdatabase missing"
fi

if [ -d /etc/passwd ]
then 
	echo "this is directory"
else
	echo "this is not a directory"
fi



