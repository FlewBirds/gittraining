#!/bin/bash

#echo -n "Enter a value: "
#read inputval
inputval=$1
case $inputval in [0-9])
	echo "entered value is a single digit"
	;;
   [1-9][1-9])
	   echo "entered value is a double digit"
	   ;;
   *)
	   echo "entered value is more than double digit"
esac
