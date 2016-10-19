#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")"&&pwd)/src"
set -e

export PROCDIR
export T1_RAW
export PET_RAWS
export ATLAS_IMG
export REQ_STAT="-M -V -S"
# Just create directories
DO_NOTHING=YES source ${SRC_DIR}/../SSP/ssp.sh

(
${SRC_DIR}/mri.0.init.sh
${SRC_DIR}/mri.1.brain.extraction.sh
${SRC_DIR}/mri.2.gm.segmentation.sh
${SRC_DIR}/mri.3.mni.registeration.sh
#${SRC_DIR}/mri.2.gm.segmentation.atlas.brain.mask.sh

${SRC_DIR}/pet.0.init.sh
${SRC_DIR}/pet.1.register.to.t1.sh
${SRC_DIR}/pet.2.resample.atlas.to.pet.sh
${SRC_DIR}/pet.3.report.atlas.sh

${SRC_DIR}/mri.4.resample.pet.atlas.sh
${SRC_DIR}/mri.5.report.atlas.sh

) 1> ${RERUNDIR}/pipeline.${start_time}.sh
