#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${ATLAS_IMG}" "${PETDIR}/pet.sum.reorient.nii.gz" "${MRIDIR}/t1.brain_pve_1.nii.gz"
depends_on "${TRANSDIR}/mni.to.t1_coef.nii.gz" "${TRANSDIR}/t1.to.pet.mat"

# Expected output files
expects "${PETDIR}/atlas.on.pet.nii.gz"
expects "${PETDIR}/gm.atlas.on.pet.nii.gz"
expects "${PETDIR}/t1.brain_pve_1.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.resample.atlas.to.pet ${FSLPRE}applywarp --ref="${PETDIR}/pet.sum.reorient.nii.gz" \
                                                       --in="${ATLAS_IMG}" \
                                                       --out="${PETDIR}/atlas.on.pet.nii.gz" \
                                                       --warp="${TRANSDIR}/mni.to.t1_coef.nii.gz" \
                                                       --postmat="${TRANSDIR}/t1.to.pet.mat" \
                                                       --interp=nn

run_and_log 2.resample.gm.to.pet ${FSLPRE}flirt -in "${MRIDIR}/t1.brain_pve_1.nii.gz" \
												-ref "${PETDIR}/pet.sum.reorient.nii.gz" \
												-applyxfm -init "${TRANSDIR}/t1.to.pet.mat" \
												-out "${PETDIR}/t1.brain_pve_1.nii.gz"

run_and_log 3.create.gm.atlas.on.pet ${FSLPRE}fslmaths "${PETDIR}/t1.brain_pve_1.nii.gz" -thr 0.5 -bin -mul "${PETDIR}/atlas.on.pet.nii.gz" "${PETDIR}/gm.atlas.on.pet.nii.gz"