import nibabel as nib
import numpy as np
import sys

def main(regions,outfile):
    path="../data/parcellation/shen/Shen_1mm_368_parcellation_resize.nii.gz"
    par=nib.load(path)
    data=par.get_fdata()
    #regions=input("enter the regions\n").split(", ")
    #outfile=input("enter out file name\n")
    regions=[int(i) for i in regions]
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            for k in range(data.shape[2]):
                if data[i,j,k] not in regions:
                    data[i,j,k]=0
    nib.Nifti1Image(data,par.affine,par.header).to_filename(outfile)
if __name__ == '__main__':
    regions=np.loadtxt(sys.argv[1])
    outfile=sys.argv[2]
    main(regions,outfile)