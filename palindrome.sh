#!/bin/bash
set -ex

echo "Enter a string to check weather it is a palindrome or not"

PALINDROME_VAR=$1

REVERSE=""

PALINDROME_LEN=${#PALINDROME_VAR}

for (( i=$PALINDROME_LEN-1; i>=0; i-- ))
do 
	REVERSE="$REVERSE${PALINDROME_VAR:$i:1}"

done

if [ $PALINDROME_VAR == $REVERSE ]

then
	echo "$PALINDROME_VAR is a polindrome word"

else
	echo "$PALINDROME_VAR is not a polindrome word"

fi

