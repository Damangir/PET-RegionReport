#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
if [ ! "${PET_RAWS}" ]
then
  error "PET_RAWS Should be specified either as list or a wildcard."
  exit 1
fi

for this_pet in $(echo "${PET_RAWS}")
do
depends_on "${this_pet}"
done

# Expected output files
expects "${PETDIR}/pet.sum.nii.gz"
expects "${PETDIR}/pet.sum.reorient.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.sum.pet ${FSLPRE}fslmaths $(pjoin " -add " $(echo "${PET_RAWS}")) "${PETDIR}/pet.sum.nii.gz"
run_and_log 2.reorient.pet ${FSLPRE}fslreorient2std "${PETDIR}/pet.sum.nii.gz" "${PETDIR}/pet.sum.reorient.nii.gz"
