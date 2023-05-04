#!/bin/bash
dir="../data/subjects"
i=0
for subject in `ls ${dir}`
do
    cont=0
    for file in `ls $dir/$subject/release-notes`
    do
        cont=`expr $cont + 1`
    done
    if [ $cont != 8 ]
    then
        echo $subject
    fi
    i=`expr $i + 1`
done
