#!/bin/bash
date; who
echo "This is my first script 'Hello World!!'"

echo "username is : $USER"
echo "UID is : $UID"
echo "home directory is : $HOME"

mkdir -p $HOME/$USER-$ID

ls -lrth $HOME/

VARIABLE1="variable"
VARIABLE_NUM=200
VARIABLE2=testing
echo "VARIABLE1: $VARIABLE1, VARIABLE_NUM: $VARIABLE_NUM, VARIABLE2: $VARIABLE2"

today=$(date +%Y%m%d)
echo "today date is: $today"
