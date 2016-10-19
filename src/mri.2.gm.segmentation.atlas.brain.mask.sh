#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
depends_on "${TRANSDIR}/mni.to.t1_coef.nii.gz"
depends_on "${MRIDIR}/t1.reorient.nii.gz"
depends_on "${ATLAS_IMG}"

# Expected output files
expects "${MRIDIR}/t1.brain.nii.gz"
expects "${MRIDIR}/t1.brain_pve_1.nii.gz" "${MRIDIR}/t1.brain.gm.nii.gz"


# Check if we need to run this stage
check_already_run
remove_expected_output


run_and_log 0.1.resample.atlas.to.t1 ${FSLPRE}applywarp  --ref="${MRIDIR}/t1.reorient.nii.gz" \
                                                       --in="${ATLAS_IMG}" \
                                                       --out="${MRIDIR}/atlas.on.t1.nii.gz" \
                                                       --warp="${TRANSDIR}/mni.to.t1_coef.nii.gz" \
                                                       --interp=nn
run_and_log 0.2.new.brain.extraction ${FSLPRE}fslmaths "${MRIDIR}/atlas.on.t1.nii.gz" -bin -mul "${MRIDIR}/t1.reorient.nii.gz" "${MRIDIR}/t1.brain.nii.gz"

run_and_log 0.3.qc.bmask.t1 ${FSLPRE}slices "${MRIDIR}/t1.reorient.nii.gz" "${MRIDIR}/t1.brain.nii.gz" -o "${QCDIR}"/${STAGE}.brain_mask.gif

run_and_log 1.fast.t1 ${FSLPRE}fast "${MRIDIR}/t1.brain.nii.gz" --type=1 --class=3 --out "${MRIDIR}/t1.brain"
run_and_log 2.extract.gm.t1 ${FSLPRE}fslmaths "${MRIDIR}/t1.brain_pve_1.nii.gz" -thr 0.5 "${MRIDIR}/t1.brain.gm.nii.gz"
run_and_log 3.qc.gm.seg.t1 ${FSLPRE}slices "${MRIDIR}/t1.brain.nii.gz" "${MRIDIR}/t1.brain.gm.nii.gz" -o "${QCDIR}"/${STAGE}.gm_mask.gif


