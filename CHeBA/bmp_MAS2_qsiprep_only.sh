#!/bin/bash

# DESCRIPTION :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   This script goes through the pipelines to process imaging data
#   for VCI study.
#
# COMPUTATIONAL RESOURCES :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   The processing can be carried out on Katana, through OnDemand
#   service. A node with 16 CPU cores and 128 GB of memory for 12
#   hours is enough for the processing. Note that each step is run
#   separately, meaning that for each processing step a VM of 16
#   CPU cores and 128 GB of memory is needed.
#
# OUTPUTS :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   - [aslprep] - BASIL CBF results can be found in
#                 /path/to/aslprep/work_dir/subject_ID/aslprep_wf/
#                 single_subject_vci001_wf/asl_preproc_dir_PA_wf/
#                 compute_cbf_wf/extract_deltam/native_space.
#                 For example, vci001's results can be found in
#                 /srv/scratch/cheba/Imaging/my_tmp/aslprep_work/
#                 vci001/aslprep_wf/single_subject_vci001_wf/
#                 asl_preproc_dir_PA_wf/compute_cbf_wf/
#                 extract_deltam/native_space.
# 
#
# LOG :
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#   - [qsiprep] - mrtrix_multishell_msmt_pyafq_tractometry constantly having 
#                 "No space left on device" error.
#
#   - [qsiprep] - Preprocessed dMRI data are upsampled to 1.2 mm isotropic 
#                 because fixel-based analyses require a minimum of 1.3 mm 
#                 isotropic. However, this means other reconstrctions 
#                 (e.g., noddi) will also be based on 1.2 mm isotropic results.
#
#   - [fmriprep] - To let fmriprep finds fmaps, rsfMRI and fmap 
#                  JSON files need specify "B0FieldSource" and 
#                  "B0FieldIdentifier".
#
#   - [aslprep] -  It seems ASL-BIDS does not accept blip-up/down
#                  like dMRI and fMRI. Instead, it requires an
#                  additional m0scan with reverse PE from the
#                  main m0scan. A BIDS example can be found at:
#                  https://github.com/bids-standard/bids-examples/tree/master/asl004/sub-Sub1/fmap.
#                  Reference: https://www.nature.com/articles/s41597-022-01615-9.
#                  Therefore, add --use-syn-sdc and --force-syn
#                  to enable fieldmap-less distortion correction.


# Katana
module load matlab/R2023b

export DICOM_zip=$1
export BIDS_dir=$2
export subject_ID=$3

omp=16 # max num of threads per process

bids_validator_version=1.13.1
mriqc_version=23.1.0
qsiprep_version=0.19.1
smriprep_version=0.12.2
aslprep_version=0.6.0
fmriprep_version=23.1.4


# +++++++++++++++++++++++++++++++++++++++++++++++++
#
# References : https://qsiprep.readthedocs.io/en/latest/preprocessing.html#merge-denoise

# Edit the Affine header to match header across all DWI scans
#${BIDS_dir}/$subject_ID/dwi/${subject_ID}_dir-AP_run-1_dwi.nii.gz
python3 $BMP_PATH/CHeBA/align_affine_header.py ${BIDS_dir} ${subject_ID}

work_dir=${BIDS_dir}/derivatives/qsiprep_${qsiprep_version}/work/$subject_ID

mkdir -p $work_dir

singularity run --containall --writable-tmpfs \
                -B ${BIDS_dir} \
                -B ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version} \
                -B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
                -B $BMP_PATH/CHeBA/bmp_MAS2_qsiprep_eddy_param.json:/opt/eddy_param.json \
		-B $BMP_PATH \
                -B $work_dir \
                $BMP_3RD_PATH/qsiprep-${qsiprep_version}.sif \
                ${BIDS_dir} \
                ${BIDS_dir}/derivatives/qsiprep_${qsiprep_version} \
                participant \
                --skip_bids_validation \
                --participant_label ${subject_ID} \
                --fs-license-file /opt/freesurfer/license.txt \
                --unringing-method mrdegibbs \
                --denoise-after-combining \
                --output-resolution 1.2 \
                --anat_modality T1w \
                --hmc_model eddy \
                --eddy_config /opt/eddy_param.json \
                --pepolar_method TOPUP \
                --work_dir $work_dir \
                --omp_nthreads $omp \
                -v


# Reconstruction DWI measures (qsiprep)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#

qsiprep_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsiprep
# output_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsirecon/$spec
freesurfer_dir=$BIDS_dir/derivatives/smriprep_${smriprep_version}/freesurfer

for spec in mrtrix_multishell_msmt_ACT-hsvs \
            amico_noddi \
            dsi_studio_gqi

    output_dir=$BIDS_dir/derivatives/qsiprep_${qsiprep_version}/qsirecon_$spec
    work_dir=$output_dir/work/$subject_ID

    mkdir -p $work_dir

    singularity run --containall --writable-tmpfs \
                    -B $BMP_TMP_PATH/templateflow:/home/qsiprep/.cache/templateflow \
                    -B $qsiprep_dir \
                    -B $output_dir \
                    -B $freesurfer_dir \
                    -B $work_dir \
                    -B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
		    -B $BMP_PATH \
                    $BMP_3RD_PATH/qsiprep-${qsiprep_version}.sif \
                    $qsiprep_dir $output_dir \
                    participant \
                    --skip_bids_validation \
                    --recon_only \
                    --participant_label ${subject_ID} \
                    --recon_input $qsiprep_dir \
                    --recon_spec $spec \
                    --freesurfer_input $freesurfer_dir \
                    --fs-license-file /opt/freesurfer/license.txt \
                    --work_dir $work_dir \
                    --omp_nthreads $omp \
                    -v
end

