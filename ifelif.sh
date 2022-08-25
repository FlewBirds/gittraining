#!/bin/bash

age="skldjf"

if [  $age -gt 40 ]

then
	echo "aged above 40"
elif [ $age == 40 ]
then
	echo "age matching"
elif [ $age -lt 40 ]
then
	echo "young man"
else
	echo "given vlaue is not valid"
fi



