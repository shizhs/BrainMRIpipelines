#!/bin/bash

echo_success() {
    echo -e "\e[32m$1\e[0m"
}

echo_error() {
    echo -e "\e[31m$1\e[0m"
}

parse_arguments() {
    smriprep_version="0.12.2"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --bids_dir)
                BIDS_dir="$2"
                shift 2
                ;;
            --BIDS_ID)
                BIDS_ID="$2"
                shift 2
                ;;
            --smriprep_version)
                smriprep_version="$2"
                shift 2
                ;;
            *)
                echo_error "Usage: $0 --bids_dir <bids_dir> --BIDS_ID <BIDS_ID> --smriprep_version <smriprep_version>"
                exit 1
                ;;
        esac
    done

    if [[ -z "$BIDS_dir" || -z "$BIDS_ID" || -z "$smriprep_version" ]]; then
        echo_error "Error: Both --bids_dir and --BIDS_ID are required."
        echo_error "Usage: $0 --bids_dir <bids_dir> --BIDS_ID <BIDS_ID>"
        exit 1
    fi
}

# Call the function with all command-line arguments
parse_arguments "$@"

freesurfer_dir=${BIDS_dir}/derivatives/smriprep_${smriprep_version}/freesurfer/sub-${BIDS_ID}

# check if the freesurfer folder exists
if [ ! -d "$freesurfer_dir" ]; then
    echo_error "Error: The freesurfer folder does not exist for subject ${BIDS_ID}."
    exit 1
fi

# check if recon-all finished without error
recon_all_log=${freesurfer_dir}/scripts/recon-all.log
if [ ! -f "$recon_all_log" ]; then
    echo_error "Error: The recon-all log file does not exist for subject ${BIDS_ID}."
    exit 1
fi

# check if last line of the log file include "recon-all -s sub-${BIDS_ID} finished without error"
last_line=$(tail -n 1 "$recon_all_log")
if [[ "$last_line" != *"recon-all -s sub-${BIDS_ID} finished without error"* ]]; then
    echo_error "Error: The recon-all did not finish without error for subject ${BIDS_ID}."
    exit 1
fi

echo_success "The recon-all finished without error for subject ${BIDS_ID}."