#!/bin/bash

usage() {

cat << EOF

$(basename $0)

DESCRIPTION

  This script converts DICOM downloaded from Flywheel to BIDS format. It is customised
  for VCI study at CHeBA.


USAGE

  $(basename $0) {-d|--dicom_zip} <DICOM zip archive from Flywheel> 
                 {-b|--bids_dir} <output BIDS directory>
                 [{-j|--json} <path to JSON file>]


COMPULSORY

  -s, --study                 <study>                'VCI' or 'CADSYD' study.

  -d, --dicom_zip             <DICOM zip archive>    Path to DICOM zip file downloaded
                                                     from Flywheel.

  -b, --bids_dir              <BIDS directory>       Path to output BIDS directory.

  -i, --subj_id               <subject ID>           Subject's ID.


OPTIONAL

  -1, --is_1st_run            <Y/N>                  Whether is first run. If Y, call
                                                     'bmp_BIDS_CHeBA_dcm2bids_1stRun.sh'
                                                     for generating configure json file.
                                                     Otherwise, call 'bmp_BIDS_CHeBA
                                                     _dcm2bids_followRuns.sh'. Default 
                                                     is N.

  -j, --json                  <path to JSON file>    Path to config JSON file, if not
                                                     using default.

  -h, --help                                         Display this message.


EOF

}

is_first_run=N

for arg in "$@"
do
  case $arg in
    -s|--study)
        study=$2
        json=$BMP_PATH/BIDS/config_files/${2}_config.json
        shift 2
        ;;
    -d|--dicom_zip)
        DICOM_zip=$2
        shift 2
        ;;
    -b|--bids_dir)
        BIDS_dir=$2
        shift 2
        ;;
    -i|--subj_id)
        subject_ID=$2
        shift 2
        ;;
    -1|--is_1st_run)
        is_first_run=Y
        shift 2
        ;;
    -j|--json)
        json=$2
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    -*)
        echo "[$(date)] : $(basename) : Unknown flag $arg."
        usage
        exit 1
        ;;
  esac
done

echo "DICOM zip = ${DICOM_zip}"
echo "BIDS dir = ${BIDS_dir}"
echo "Subject ID = ${subject_ID}"
echo "Study = ${study}"

case $is_first_run in
    Y)
        bmp_BIDS_CHeBA_dcm2bids_1stRun.sh $DICOM_zip $BIDS_dir $subject_ID $study
        ;;
    N)
        bmp_BIDS_CHeBA_dcm2bids_followingRuns.sh $DICOM_zip $BIDS_dir $subject_ID $study

        echo "Fixing IntendedFor ... "

        matlab -nodisplay -nosplash -nodesktop -r \
                "addpath(fullfile(getenv('BMP_PATH'),'BIDS'));bmp_BIDS_CHeBA_chkIntendedFor('$BIDS_dir','$subject_ID','$study');exit"

        echo -ne "Tailoring M0 scan ... "

        bmp_BIDS_CHeBA_tailorM0scan.sh $BIDS_dir $subject_ID

        echo "DONE!"

        echo -ne "Fixing RepetitionTimePreparation field ... "

        matlab -nodisplay -nosplash -nodesktop -r \
                "addpath(fullfile(getenv('BMP_PATH'),'BIDS'));bmp_BIDS_CHeBA_fixReversePEm0RepetitionTimePreparation('$BIDS_dir','$subject_ID','$study');exit"

        echo "DONE!"
        ;;
esac