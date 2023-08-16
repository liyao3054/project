#!/bin/bash
info=($(cat ./tempdata/region_cor))
atlas="./tempdata/temp"
cat /dev/null > $atlas
for i in {1..368}
do
    region=$i
    x=${info[$((4*i-3))]}
    y=${info[$((4*i-2))]}
    z=${info[$((4*i-1))]}
    #echo $i >> $atlas
    content=$(atlasquery -a "Talairach Daemon Labels" -c $x,$y,$z)
    echo ${content#*<br>} >> $atlas
done