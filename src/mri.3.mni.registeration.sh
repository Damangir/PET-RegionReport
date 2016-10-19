#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

ATLAS_IMG=${MNIDIR}/MNI152_T1_2mm.nii.gz
ATLAS_IMG_BRAIN=${MNIDIR}/MNI152_T1_2mm_brain.nii.gz

# Expected input files
depends_on "${ATLAS_IMG}" "${ATLAS_IMG_BRAIN}" "${MRIDIR}/t1.reorient.nii.gz" "${MRIDIR}/t1.brain.nii.gz"


# Expected output files
expects "${TRANSDIR}/t1.to.mni.mat" "${TRANSDIR}/mni.to.t1.mat"
expects "${TRANSDIR}/t1.to.mni_coef.nii.gz" "${TRANSDIR}/mni.to.t1_coef.nii.gz"

# Check if we need to run this stage
check_already_run
remove_expected_output

run_and_log 1.linear_registration ${FSLPRE}flirt -ref "${ATLAS_IMG_BRAIN}" -in "${MRIDIR}/t1.brain.nii.gz" -omat "${TRANSDIR}/t1.to.mni.mat" -out "${MRIDIR}/t1.to.mni.lin.nii.gz"
run_and_log 2.invert ${FSLPRE}convert_xfm -omat "${TRANSDIR}/mni.to.t1.mat" -inverse "${TRANSDIR}/t1.to.mni.mat"
run_and_log 3.QC_linear ${FSLPRE}slices "${ATLAS_IMG}" "${MRIDIR}/t1.to.mni.lin.nii.gz" -o "${QCDIR}/${STAGE}.t1_on_mni_lin.gif"

run_and_log 4.nonlinear_registration ${FSLPRE}fnirt --ref="${ATLAS_IMG}" --in="${MRIDIR}/t1.reorient.nii.gz" --aff="${TRANSDIR}/t1.to.mni.mat" --cout="${TRANSDIR}/t1.to.mni_coef.nii.gz" --iout="${MRIDIR}/t1.in.mni.nii.gz" --config=T1_2_MNI152_2mm 
run_and_log 5.inverting_nonlinear_registration ${FSLPRE}invwarp --ref="${MRIDIR}/t1.reorient.nii.gz" --warp="${TRANSDIR}/t1.to.mni_coef.nii.gz" --out="${TRANSDIR}/mni.to.t1_coef.nii.gz"
run_and_log 6.QC_nonlinear ${FSLPRE}slices "${MRIDIR}/t1.in.mni.nii.gz" "${ATLAS_IMG}" -o "${QCDIR}/${STAGE}.t1_on_mni.gif"

