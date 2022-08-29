#!/bin/bash
NAME=(vijay sangamesh kishore ramesh)
ID_NAME=(vi001 sa002 ki003 ra004)
ARRAY1=${#NAME[*]}
ARRAY2=${#ID_NAME[*]}

if [ $ARRAY1 == $ARRAY2 ] ; then 
	for i in $(seq 0 $ARRAY1)
		do
			echo "Name:${NAME[i-1]} : ID:${ID_NAME[i-1]}"

		done
	else
		echo "elements count is not matching ${#NAME[*]} and ${#ID_NAME[*]}";

fi

