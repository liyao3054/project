#!/bin/bash
#info="../data/parcellation/shen/shen_368_BAindexing_MNI"
#values=($(grep "^[0-9]*," $info -o | grep "^[0-9]*" -o))
info="../data/parcellation/shen/area_index"
values=($(cat $info))
dir="../data/prepro"
for subject in `ls $dir`
do 
    rel_path="${subject}/unprocessed/3T"
    for  category in `ls ${dir}/$rel_path`
    do
        if [ ${category:0:1} == "t" ]
        then
            data="${dir}/${rel_path}/${category}/${subject}_3T_${category}_mcf.nii.gz"
            par="${dir}/${rel_path}/${category}/${subject}_3T_${category}_parc.nii.gz"
            temp_mask="${dir}/${rel_path}/${category}/temp_mask.nii.gz"
            #temp_result="${dir}/${rel_path}/${category}/temp_result.nii.gz"
            mkdir -p ../data/pre_results/$subject/$category/
            timeseries="../data/pre_results/$subject/$category/timeseries"
            rm $timeseries
            for i in ${values[*]}
            do
                #echo $i
                fslmaths $par -thr $i -uthr $i -bin $temp_mask
                #fslmaths $data -mul $temp_mask $temp_result
                series=($(fslmeants -i $data -m $temp_mask))
                echo ${series[*]} >> $timeseries
                #exit 0
            done
            #exit 0
        fi
        #mkdir -p ../data/pre_results/$subject/$category/
        #cp $timeseries ../data/pre_results/$subject/$category/timeseries
    done
    rm -r $dir/$subject
done
