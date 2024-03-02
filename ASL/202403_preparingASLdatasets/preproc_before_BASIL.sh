#!/bin/bash

# Data stored in /data_int/jiyang/tmp/work on GRID

work_dir=/data_int/jiyang/tmp/work

# fsl_anat
for_each -nthreads 40 ${work_dir}/P*/*-* : fsl_anat -i IN/t1 -o IN/t1

# extract M0 for PASL
for_each -nthreads 40 ${work_dir}/PASL/*-* : fslroi IN/asl IN/m0 0 1
for_each -nthreads 40 ${work_dir}/PASL/*-* : fslroi IN/asl IN/asl 1 -1
for_each -nthreads 40 ${work_dir}/PASL/*-* : rm -f IN/asl.nii
for_each -nthreads 40 ${work_dir}/PASL/*-* : gunzip IN/*.gz

# segment lateral ventricles
for_each -nthreads 40 ${work_dir}/P*/*-* : mkdir -p IN/ventricle
for_each -nthreads 40 ${work_dir}/P*/*-* : matlab -nodesktop -nodisplay -r \"addpath\(fullfile\(getenv\(\'BMP_PATH\'\),\'misc\'\)\)\;bmp_misc_getLatVent\(\'IN/m0.nii\',\'IN/t1.nii\',\'IN/ventricle\'\)\;exit\"