#!/bin/bash
indir="../data/subjects"
outdir="../data/prepro"
shen="../data/parcellation/shen/Shen_1mm_368_parcellation_resize.nii.gz"
for subject in `ls $indir`
do
    rel_path="${subject}/unprocessed/3T"
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
            flirt -in ${t1data} -ref ${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz -out ${t1result} -omat ${t1affine}
            bet ${t1data} ${t1brain}
            convert_xfm -omat ${t1affine_inverse} -inverse ${t1affine}
            #exit 0
            for  category in `ls ${indir}/$rel_path`
            do
                if [ ${category:0:1} == "t" ]
                then
                    mkdir -p ${outdir}/${rel_path}/${category}
                    tfdata="${indir}/${rel_path}/${category}/${subject}_3T_${category}.nii.gz"
                    SBRef="${indir}/${rel_path}/${category}/${subject}_3T_${category}_SBRef.nii.gz"
                    brainRef="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_brain.nii.gz"
                    mcf_result="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_mcf.nii.gz"
                    mcflirt -in ${tfdata} -out ${mcf_result} -reffile ${SBRef}
                    bet ${SBRef} ${brainRef}
                    flirt_result="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt.nii.gz"
                    flirt_affine="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt.mat"
                    flirt -in ${brainRef} -ref ${t1brain} -out ${flirt_result} -omat ${flirt_affine}
                    flirt_affine_inverse="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_flirt_inverse.mat"
                    convert_xfm -omat ${flirt_affine_inverse} -inverse ${flirt_affine}
                    conc_affine="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_conc_inverse.mat"
                    convert_xfm -omat ${conc_affine} -concat ${flirt_affine_inverse} ${t1affine_inverse}
                    parc="${outdir}/${rel_path}/${category}/${subject}_3T_${category}_parc.nii.gz"
                    flirt -in ${shen} -applyxfm -init ${conc_affine} -out ${parc} -paddingsize 0.0 -interp nearestneighbour -ref ${SBRef}
                    #exit 0
                fi
            done
        fi
    done
    exit 0
done