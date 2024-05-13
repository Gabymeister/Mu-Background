#!/bin/bash

TENTHOUSANDS=5

for (( i=1; i <=$TENTHOUSANDS; i++ ))
do
	sbatch sbatch_all.sh
	echo "submitted bash job ${i}"
	sleep 10
done
