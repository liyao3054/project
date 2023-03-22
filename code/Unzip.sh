#!/bin/bash
dir="../data/subjects"
i=1
for temp_file in `ls ${dir}`
do 
    if [ ${temp_file##*.} = "md5" ]
    then
        rm $dir/$temp_file
        #unzip -d $dir $dir/$temp_file
    fi
    #rm $dir/$temp_file
    echo $i
    i=`expr $i + 1`
done