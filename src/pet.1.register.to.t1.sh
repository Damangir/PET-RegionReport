#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${PETDIR}/pet.sum.reorient.nii.gz" "${MRIDIR}/t1.brain.nii.gz"

# Expected output files
expects "${TRANSDIR}/t1.to.pet.mat" "${TRANSDIR}/pet.to.t1.mat"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.linear_registration ${FSLPRE}flirt -ref "${MRIDIR}/t1.brain.nii.gz" -in "${PETDIR}/pet.sum.reorient.nii.gz" -dof 6 -omat "${TRANSDIR}/pet.to.t1.mat"  -out "${PETDIR}/pet.on.t1.nii.gz" 
run_and_log 2.invert ${FSLPRE}convert_xfm -omat "${TRANSDIR}/t1.to.pet.mat" -inverse "${TRANSDIR}/pet.to.t1.mat"
run_and_log 3.QC_linear ${FSLPRE}slices "${MRIDIR}/t1.brain.nii.gz" "${PETDIR}/pet.on.t1.nii.gz"  -o "${QCDIR}/${STAGE}.pet.on.t1.gif"
