#!/bin/bash
#set -ex
# Print Fibonacci Series with range 0 to 10

# X(0)+Y(1)  = fn (1) i=1
# X(1)+Y(1)  = fn (2) i=2
# X(1)+Y(2)  = fn (3) i=3
# x(2)+Y(3)  = fn (5) i=4
# x(3)+y(5)  = fn (8) i=5
# x(5)+y(8)  = fn (13)i=6
# x(8)+y(13) = fn (21)i=7
# x(13)+y(21)= fn (34)i=8


RANGE=10

x=0
y=1

for((i=1; i<=RANGE; i++))

do 
 #   echo "$i $x"
	fn=$((x+y)) 
	x=$y         
	y=$fn        
     echo "Iteration:$i X: $x + Y: $y = FIBONACCI: $fn"

done

