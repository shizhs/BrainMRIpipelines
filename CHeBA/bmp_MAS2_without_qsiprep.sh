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


# Create dcm2bids configuration file.
# ++++++++++++++++++++++++++++++++++++++++++++
# 0.1 - reorganise DICOM folders, and run helper function.
#bmp_BIDS_CHeBA.sh --study MAS2 --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID --is_1st_run
# 0.2 - generate configuration file.
# MATLAB ==>> vci_config = bmp_BIDS_CHeBA_genVCIconfigFile('rsfMRI'); % edit matchings
# 0.3 - tidy up.
# edit BrainMRIPipelines/BIDS/config_files/MAS2_config.json to remove [] lines.

# dcm2bids for subsequent scans.
# +++++++++++++++++++++++++++++++++++++++
#conda activate dcm2bids

## TODO commenting out just for testing
bmp_BIDS_CHeBA.sh --study MAS2 --dicom_zip $DICOM_zip --bids_dir $BIDS_dir --subj_id $subject_ID

# validate BIDS
# +++++++++++++++++++++++++++++++++++++++
# bmp_BIDSvalidator.sh --bids_directory $BIDS_dir --docker
#
# Or directly run in docker
#
# docker run -ti --rm -v ${BIDS_dir}:/data:ro bids/validator /data
#
# OR
singularity run --cleanenv \
                --bind ${BIDS_dir}:/data:ro \
                $BMP_3RD_PATH/bids-validator-${bids_validator_version}.sif \
                /data

# MRIQC (subject level)
# +++++++++++++++++++++++++++++++++++++++
# docker run -it --rm -v ${BIDS_dir}:/data:ro -v ${BIDS_dir}/derivatives/mriqc/sub-$subject_ID:/out nipreps/mriqc /data /out participant --modalities {T1w,T2w,bold,dwi} --verbose-reports --species human --deoblique --despike --mem_gb 4  --nprocs 1 --no-sub
#
# OR
#
mkdir -p ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work

singularity run --cleanenv \
                -B ${BIDS_dir}:/data \
                -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}:/out \
                -B ${BIDS_dir}/derivatives/mriqc_${mriqc_version}/work:/work \
                $BMP_3RD_PATH/mriqc-${mriqc_version}.sif \
                /data /out \
                participant \
                --work-dir /work \
                --participant_label ${subject_ID} \
                -m {T1w,T2w,bold} \
                --verbose-reports \
                --species human \
                --deoblique \
                --despike \
                --no-sub \
                -v

# Pre-processing sMRI (smriprep)
# +++++++++++++++++++++++++++++++++++++++
#
mkdir -p ${BIDS_dir}/derivatives/smriprep_${smriprep_version}/work

export FS_LICENSE=$FREESURFER_HOME/license.txt
singularity run --cleanenv \
		-B $BIDS_dir \
		-B $FREESURFER_HOME/license.txt:/opt/freesurfer/license.txt \
		-B ${BIDS_dir}/derivatives/smriprep_${smriprep_version}/work:/work \
                $BMP_3RD_PATH/smriprep-${smriprep_version}.simg \
                ${BIDS_dir} ${BIDS_dir}/derivatives/smriprep_${smriprep_version} \
                participant \
                --participant_label ${subject_ID} \
                --omp-nthreads $omp \
                --fs-license-file /opt/freesurfer/license.txt \
                --work-dir /work \
                --notrack \
                -v


# Processing ASL (ASLPrep)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
output_dir=$BIDS_dir/derivatives/aslprep_${aslprep_version}
work_dir=$BMP_TMP_PATH/aslprep_work/$subject_ID		# aslprep does not allow work dir to be a subdir of bids dir.

mkdir -p $work_dir $output_dir

singularity run --cleanenv \
				-B $HOME:/home/aslprep \
				--home /home/aslprep \
				-B $BIDS_dir \
				-B $output_dir \
				-B $work_dir \
				-B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
				$BMP_3RD_PATH/aslprep-${aslprep_version}.simg \
				$BIDS_dir $output_dir \
				participant \
				--skip_bids_validation \
				--participant_label $subject_ID \
				--omp-nthreads $omp \
				--output-spaces MNI152NLin6Asym:res-2 T1w asl \
				--force-bbr \
				--m0_scale 10 \
				--scorescrub \
				--basil \
				--use-syn-sdc \
				--force-syn \
				--fs-license-file /opt/freesurfer/license.txt \
				--work-dir $work_dir \
				-v


# Preprocessing rsfMRI (fMRIPrep)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
output_dir=$BIDS_dir/derivatives/fmriprep_${fmriprep_version}
work_dir=$BMP_TMP_PATH/fmriprep_work/$subject_ID
freesurfer_dir=$BIDS_dir/derivatives/smriprep_${smriprep_version}/freesurfer

mkdir -p $work_dir $output_dir

singularity run --cleanenv \
				-B $BIDS_dir \
				-B $output_dir \
				-B $work_dir \
				-B $freesurfer_dir \
				-B ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
				-B $BMP_TMP_PATH/templateflow:/home/fmriprep/.cache/templateflow \
				-B $BMP_TMP_PATH/matplotlib:/home/fmriprep/.config/matplotlib \
				$BMP_3RD_PATH/fmriprep-${fmriprep_version}.simg \
				$BIDS_dir $output_dir \
				participant \
				--skip_bids_validation \
				--participant_label $subject_ID \
				--omp-nthreads $omp \
				--output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym:res-2 fsaverage:den-10k anat func \
				--force-bbr \
				--me-t2s-fit-method curvefit \
				--project-goodvoxels \
				--medial-surface-nan \
				--cifti-output 91k \
				--return-all-components \
				--fs-license-file /opt/freesurfer/license.txt \
				--fs-subjects-dir $freesurfer_dir \
				--work-dir $work_dir \
				-v


