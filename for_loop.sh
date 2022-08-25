#!/bin/bash

# for loop


for (( i=0; i <=100; i=i+20 ))
do
	echo "value of i is: $i"
	if [ $i == 21 ]
	then
		continue
	fi
done
