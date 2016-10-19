#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${MRIDIR}/t1.reorient.nii.gz"

# Expected output files
expects "${MRIDIR}/t1.brain.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

mkdir -p "${MRIDIR}"

run_and_log 1.bet.t1 ${FSLPRE}bet "${MRIDIR}/t1.reorient.nii.gz" "${MRIDIR}/t1.brain" -m
run_and_log 2.qc.bet.t1 ${FSLPRE}slices "${MRIDIR}/t1.reorient.nii.gz" "${MRIDIR}/t1.brain_mask.nii.gz" -o "${QCDIR}"/${STAGE}.brain_mask.gif
