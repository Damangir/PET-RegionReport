#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${ATLAS_IMG}" "${PETDIR}/pet.sum.reorient.nii.gz" "${MRIDIR}/t1.brain.nii.gz" "${MRIDIR}/t1.brain.gm.nii.gz"
depends_on "${TRANSDIR}/mni.to.t1_coef.nii.gz" "${TRANSDIR}/pet.to.t1.mat"

# Expected output files
expects "${MRIDIR}/atlas.on.t1.nii.gz"
expects "${MRIDIR}/gm.atlas.on.t1.nii.gz"
expects "${PETDIR}/pet.sum.t1.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.resample.atlas.to.t1 ${FSLPRE}applywarp --ref="${MRIDIR}/t1.brain.nii.gz" \
                                                       --in="${ATLAS_IMG}" \
                                                       --out="${MRIDIR}/atlas.on.t1.nii.gz" \
                                                       --warp="${TRANSDIR}/mni.to.t1_coef.nii.gz" \
                                                       --interp=nn

run_and_log 2.resample.pet.to.t1 ${FSLPRE}flirt -in "${PETDIR}/pet.sum.reorient.nii.gz" \
												-ref "${MRIDIR}/t1.brain.nii.gz" \
												-applyxfm -init "${TRANSDIR}/pet.to.t1.mat" \
												-out "${PETDIR}/pet.sum.t1.nii.gz"

run_and_log 3.create.gm.atlas.on.t1 ${FSLPRE}fslmaths "${MRIDIR}/t1.brain.gm.nii.gz" -bin -mul "${MRIDIR}/atlas.on.t1.nii.gz" "${MRIDIR}/gm.atlas.on.t1.nii.gz"
