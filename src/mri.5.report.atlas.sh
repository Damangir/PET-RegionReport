#!/bin/bash

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

REQ_STAT=${REQ_STAT:-"-M -V -S"}   # Output stat
# Expected input files
depends_on "${PETDIR}/pet.sum.t1.nii.gz" "${MRIDIR}/gm.atlas.on.t1.nii.gz"

# Expected output files
expects "${REPORTDIR}/t1.atlas.csv"

# Check if we need to run this stage
check_already_run
remove_expected_output

THIS_OUTPUT=${CON_TEMPDIR}/output.value
function measure {
  ${FSLPRE}fslstats "${PETDIR}/pet.sum.t1.nii.gz" -k "${mask}" ${REQ_STAT} > "${THIS_OUTPUT}"
}

>${REPORTDIR}/t1.atlas.csv
for i in {1..83}
do
	mask="${CON_TEMPDIR}/mask.${i}.nii.gz"
	run_and_log 1.${i}.create.mask ${FSLPRE}fslmaths "${MRIDIR}/gm.atlas.on.t1.nii.gz" -thr ${i} -uthr ${i} -bin "${mask}"
	run_and_log 2.${i}.measure.stat measure
	printf "%d %s\n" ${i} "$(cat "${THIS_OUTPUT}")" >>${REPORTDIR}/t1.atlas.csv
done
