#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${T1_RAW}"

# Expected output files
expects "${MRIDIR}/t1.original.nii.gz" "${MRIDIR}/t1.reorient.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.import.original.t1 ${FSLPRE}fslmaths "${T1_RAW}" "${MRIDIR}/t1.original.nii.gz"
run_and_log 2.reorient.t1 ${FSLPRE}fslreorient2std "${MRIDIR}/t1.original.nii.gz" "${MRIDIR}/t1.reorient.nii.gz"
