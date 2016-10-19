declare -r DATA_DIR=$(cd "${SCRIPT_DIR}/../data"&&pwd)

declare -r QCDIR=${PROCDIR}/QC
declare -r REPORTDIR=${PROCDIR}/Report

declare -r IMAGEDIR=${PROCDIR}/Images
declare -r MRIDIR=${IMAGEDIR}/MRI
declare -r PETDIR=${IMAGEDIR}/PET

declare -r TRANSDIR=${PROCDIR}/Transformations

mkdir -p "${QCDIR}" "${REPORTDIR}" "${IMAGEDIR}" "${MRIDIR}" "${PETDIR}" "${TRANSDIR}"

declare -r MNIDIR=${FSLDIR}/data/standard
