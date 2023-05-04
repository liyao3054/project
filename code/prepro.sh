#!/bin/bash
indir="../data/subjects"
outdir="../data/prepro"
shen="../data/parcellation/shen/Shen_1mm_368_parcellation_resize.nii.gz"
info="../data/parcellation/shen/area_index"
values=($(cat $info))

logfile="./log"
touch $logfile
cat /dev/null > $logfile
fifolist="./fifolist"
mkfifo $fifolist
exec 8<>$fifolist
for ((i=0;i < 20; i++))
do
    echo >&8
done

for subject in `ls $indir`
do
    read <&8
    {
        rel_path="${subject}/unprocessed/3T"
        # processing structural data
        for t1 in `ls ${indir}/$rel_path`
        do 
            if [ ${t1:0:2} == "T1" ]
            then
                t1data="${indir}/${rel_path}/${t1}/${subject}_3T_${t1}.nii.gz"
                t1result="${outdir}/${rel_path}/${t1}/${subject}_3T_${t1}_flirt.nii.gz"
                t1brain="${outdir}/${rel_path}/${t1}/${subject}_3T_${t1}_brain.nii.gz"
                t1affine="${outdir}/${rel_path}/${t1}/${subject}_3T_${t1}_flirt.mat"
                t1affine_inverse="${outdir}/${rel_path}/${t1}/${subject}_3T_${t1}_flirt_inverse.mat"
                mkdir -p ${outdir}/${rel_path}/${t1}
                # coregistration from T1 to MNI space
                flirt -in ${t1data} -ref ${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz -out ${t1result} -omat ${t1affine}
                bet ${t1data} ${t1brain}
                convert_xfm -omat ${t1affine_inverse} -inverse ${t1affine}
            fi
        done
        # processing tfMRI data
        for  category in `ls ${indir}/$rel_path`
        do
            if [ ${category:0:1} == "t" ]
            then
                mkdir -p ${outdir}/${rel_path}/${category}
                tfdata="${indir}/${rel_path}/${category}/${subject}_3T_${category}.nii.gz"
                SBRef="${indir}/${rel_path}/${category}/${subject}_3T_${category}_SBRef.nii.gz"
                brainRef="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_brain.nii.gz"
                mcf_result="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_mcf.nii.gz"
                # motion correction 
                mcflirt -in ${tfdata} -out ${mcf_result} -reffile ${SBRef}
                # extract brain from reference volume
                bet ${SBRef} ${brainRef}
                flirt_result="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt.nii.gz"
                flirt_affine="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt.mat"
                # coregistration reference volume to T1
                flirt -in ${brainRef} -ref ${t1brain} -out ${flirt_result} -omat ${flirt_affine}
                flirt_affine_inverse="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt_inverse.mat"
                convert_xfm -omat ${flirt_affine_inverse} -inverse ${flirt_affine}
                conc_affine="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_conc_inverse.mat"
                convert_xfm -omat ${conc_affine} -concat ${flirt_affine_inverse} ${t1affine_inverse}
                parc="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_parc.nii.gz"
                # parcellation coregistration from MNI to reference volume
                flirt -in ${shen} -applyxfm -init ${conc_affine} -out ${parc} -paddingsize 0.0 -interp nearestneighbour -ref ${SBRef}
                temp_mask="${outdir}/${rel_path}/${category}/temp_mask.nii.gz"
                mkdir -p ../data/pre_results/$subject/$category/
                timeseries="../data/pre_results/$subject/$category/timeseries"
                touch $timeseries
		cat /dev/null > $timeseries
                # extract timeseries
                for i in ${values[*]}
                do
                    fslmaths $parc -thr $i -uthr $i -bin $temp_mask
                    series=($(fslmeants -i $mcf_result -m $temp_mask))
                    echo ${series[*]} >> $timeseries
                done
		temp_cnt=`wc -l $timeseries`
		if [ "$temp_cnt" != "368 $timeseries" ]
		then
			echo "$timeseries fails" >> $logfile
		fi
                #exit 0
            fi
        done
        rm -r $outdir/$subject
        echo >&8
        #exit 0
    } &
done
wait
exec 8>&-
rm -f $fifolist
