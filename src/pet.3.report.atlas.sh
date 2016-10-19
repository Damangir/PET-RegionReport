#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

REQ_STAT=${REQ_STAT:-"-M -V -S"}   # Output stat
# Expected input files
depends_on "${PETDIR}/pet.sum.reorient.nii.gz" "${PETDIR}/gm.atlas.on.pet.nii.gz"

# Expected output files
expects "${REPORTDIR}/pet.atlas.csv"

# Check if we need to run this stage
check_already_run
remove_expected_output

THIS_OUTPUT=${CON_TEMPDIR}/output.value
function measure {
  ${FSLPRE}fslstats "${PETDIR}/pet.sum.reorient.nii.gz" -k "${mask}" ${REQ_STAT} > "${THIS_OUTPUT}"
}

>${REPORTDIR}/pet.atlas.csv
for i in {1..83}
do
	mask="${CON_TEMPDIR}/mask.${i}.nii.gz"
	run_and_log 1.${i}.create.mask ${FSLPRE}fslmaths "${PETDIR}/gm.atlas.on.pet.nii.gz" -thr ${i} -uthr ${i} -bin "${mask}"
	run_and_log 2.${i}.measure.stat measure
	printf "%d %s\n" ${i} "$(cat "${THIS_OUTPUT}")" >>${REPORTDIR}/pet.atlas.csv
done