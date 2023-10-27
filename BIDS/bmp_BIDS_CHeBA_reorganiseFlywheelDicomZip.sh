#!/bin/bash

# This script re-organise DICOM zip downloaded from Flywheel, and extract 
# DICOM files to corresponding folders in BIDS/sourcedata.
#
# Written by Dr. Jiyang Jiang (18th September, 2023)
#
# Updated 27th October, 2023

deal_with_3D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword=$4
	modality_name=$5

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword" | grep ".dcm" | awk -F'flywheel' '{print $NF}')"

	echo $DICOM

	# # curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
	# curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

	# echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

	# bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dcm"
}

deal_with_4D(){

	DICOM_zip=$1
	BIDS_dir=$2
	subject_ID=$3
	zip_path_kword=$4
	modality_name=$5

	DICOM="flywheel$(unzip -l $DICOM_zip | grep "$zip_path_kword" | grep ".dicom.zip" | awk -F'flywheel' '{print $NF}')"

	echo $DICOM

	# # curr_rand_str=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 13 ; echo '')
	# curr_rand_str=$(head -c 5 /dev/random | openssl base64 | sed 's/\///g')

	# echo "unzip -o -j $DICOM_zip -d $BIDS_dir/sourcedata/$subject_ID/$modality_name $(echo $DICOM | sed 's/ /\\ /g')" > $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mkdir -p $BIDS_dir/sourcedata/$subject_ID/$modality_name

	# bash $BMP_TMP_PATH/bmp_${curr_rand_str}.sh && rm -f $BMP_TMP_PATH/bmp_${curr_rand_str}.sh

	# mv "$BIDS_dir/sourcedata/$subject_ID/$modality_name/$(echo $DICOM | awk -F/ '{print $NF}')" "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"

	# unzip -o -d $BIDS_dir/sourcedata/$subject_ID/$modality_name "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip" && rm -f "$BIDS_dir/sourcedata/$subject_ID/$modality_name/${modality_name}.dicom.zip"
}


DICOM_zip=$1
BIDS_dir=$2
subject_ID=$3



deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T1w_MPR_vNav_BW740 RMS/"							MEMPRAGE_RMS
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T1w_MPR_vNav_BW740/"								MEMPRAGE_echoes
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/t2_space_DF_BW651/"										FLAIR
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/ABCD_T2w_SPC_ vNav Iso0.8mm BW744/"						T2w
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_BLOCK_1_DIFFUSION_30DIR/"							DWI_AP_1
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_BLOCK_2_DIFFUSION_30DIR/"							DWI_AP_2
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_BLOCK_1_DIFFUSION_30DIR/"							DWI_PA_1
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_BLOCK_2_DIFFUSION_30DIR/"							DWI_PA_2
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/AP_FMAP_for DIFFUSION/"									DWI_B0_AP
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/PA_FMAP_for DIFFUSION/"									DWI_B0_PA
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Qsm/"								SWI_QSM
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_SWI_Combined/"					SWI_SWI
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_SWI_mIP_Combined/"				SWI_mIP
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Mag/"								SWI_mag
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/greME9_p31_256_Iso1mm_Pha/"								SWI_pha
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/relCBF/"												ASL_relCBF
deal_with_3D $DICOM_zip $BIDS_dir $subject_ID "/BAT/"													ASL_BAT
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/Perfusion_Weighted/"									ASL_PWI
deal_with_4D $DICOM_zip $BIDS_dir $subject_ID "/mTI16_800-3800_tgse_pcasl_3.4x3.4x4_14_31_2_24slc/"		ASL_ASL


