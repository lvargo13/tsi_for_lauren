#!/bin/bash

# Bash script to concatenate all netCDF files (all years) from each run 
# Created 9/29/15, Updated 9/25/15

# 1) loop through all 200 directories
# 2) within each directory, concatenate all .nc files

for i in {1..200}; do
	ilong=`seq -f "%03g" $i $i` 
	cd $ilong
	ncrcat *.nc Concat_$ilong.nc
	cd ..
done  


 
