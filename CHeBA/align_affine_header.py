# The solution is based on:
# - https://github.com/PennLINC/qsiprep/issues/106
# - https://github.com/PennLINC/qsiprep/issues/273
#
# Note that on VM, need to "conda activate nipy"
# before running the below in Python.
#
# The edited dMRI will replace old ones with the
# same filenames. This ensures QSIPREP recognises
# all of them and tries to merge all the blocks.
#

import nibabel as nb
import os
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Process DWI images.')
parser.add_argument('arg1', type=str, help='Base directory path to replace /srv/scratch/cheba/Imaging/vci/BIDS')
parser.add_argument('arg2', type=str, help='Subject ID to replace sub-vci020')

args = parser.parse_args()

# Define file paths based on the arguments
base_dir = args.arg1
subject_id = args.arg2

AP1_path = os.path.join(base_dir, f"{subject_id}/dwi/{subject_id}_dir-AP_run-1_dwi.nii.gz")
AP2_path = os.path.join(base_dir, f"{subject_id}/dwi/{subject_id}_dir-AP_run-2_dwi.nii.gz")
PA1_path = os.path.join(base_dir, f"{subject_id}/dwi/{subject_id}_dir-PA_run-1_dwi.nii.gz")
PA2_path = os.path.join(base_dir, f"{subject_id}/dwi/{subject_id}_dir-PA_run-2_dwi.nii.gz")

# Load the images
AP1 = nb.load(AP1_path)
AP2 = nb.load(AP2_path)
PA1 = nb.load(PA1_path)
PA2 = nb.load(PA2_path)

# Adjust the images
fixed_AP2 = nb.Nifti1Image(AP2.get_fdata(), AP1.affine, header=AP1.header)
fixed_PA1 = nb.Nifti1Image(PA1.get_fdata(), AP1.affine, header=AP1.header)
fixed_PA2 = nb.Nifti1Image(PA2.get_fdata(), AP1.affine, header=AP1.header)

# Save the adjusted images
fixed_AP2.to_filename(AP2_path)
fixed_PA1.to_filename(PA1_path)
fixed_PA2.to_filename(PA2_path)
