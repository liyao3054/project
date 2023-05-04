#!/bin/bash
dir="../data/subjects"
i=1
for temp_file in `ls ${dir}`
do 
    if [ ${temp_file##*.} = "zip" ]
    then
        unzip -d $dir $dir/$temp_file
	i=`expr $i + 1`
    fi
    #rm $dir/$temp_file
    echo $i
done
