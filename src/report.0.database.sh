#!/bin/bash

# Based on the reporting from github.com/Damangir/connectivity

source "$(cd "$(dirname "$0")/../SSP"&&pwd)/ssp.sh"

# Expected input files
REPORT_ITEMS="${REPORT_ITEMS:-${DATA_DIR}/report_items.txt}"

depends_on "${REPORT_LIST}"
depends_on "${REPORT_ITEMS}"

function get_path_for_subject {
	env -i PROCDIR=$1 EXPAND=$2 SCRIPT_DIR=$SCRIPT_DIR \
	   bash -xc 'source "$SCRIPT_DIR/directory_structure.sh";eval echo "$EXPAND"' 
}
# We don't want this function to show up in the reproduce script
declare -F | sort -u > "${CON_TEMPDIR}/old.functions.txt"

grep . ${REPORT_LIST} | while read -r subj_procdir
do
	grep . ${REPORT_ITEMS} | while read -r to_report
	do
		to_report=( $to_report );
		report_file=$(get_path_for_subject "${subj_procdir}" '${REPORTDIR}'"/${to_report[0]}")
		depends_on "${report_file}"
	done
done
# Expected output files
grep . ${REPORT_ITEMS} | while read -r to_report
do
	to_report=( $to_report );
	csv_file=${REPORTDIR}/${to_report[2]}
	expects ${csv_file}
done

# Check if we need to run this stage
check_already_run
remove_expected_output

read -r a_procdir < <(grep . ${REPORT_LIST})

function ensure_consistency {
	grep . ${REPORT_ITEMS} | while read -r to_report
	do
		to_report=( $to_report );
		local report_file=$(get_path_for_subject "${a_procdir}" '${REPORTDIR}'"/${to_report[0]}")
		local prev=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')
		while read -r subj_procdir
		do
			report_file=$(get_path_for_subject "${subj_procdir}" '${REPORTDIR}'"/${to_report[0]}")
			current_labels=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')
			if [ "${prev}" = "${current_labels}" ]
			then
				prev=${current_labels}
				printf "${current_labels}\n" >> ${QCDIR}/labels.${to_report[0]}
			else
		  	    printf "Headers in ${report_file} does not match headers in other files.\n" >&2
		        exit 1
			fi
		done< <(grep . ${REPORT_LIST})
	done
}

run_and_log 0.consistency_check ensure_consistency

function extract_values {
	local report_file=$(get_path_for_subject "${1}" '${REPORTDIR}'"/${report_source}")
	local current_values=$(cut -d ' ' -f ${field} "${report_file}" | tr '\n' ';')
	local current_id=$(basename "${1}")
    printf "${current_id};${current_values}\n" >> "${csv_file}"
}

grep . ${REPORT_ITEMS} | while read -r to_report
do
	to_report=( $to_report );
	report_source=${to_report[0]}	
	field=${to_report[1]}
	csv_file=${PROCDIR}/${to_report[2]}

	report_file=$(get_path_for_subject "${a_procdir}" '${REPORTDIR}'"/${report_source}")
	current_labels=$(cut -d ' ' -f 1 "${report_file}" | tr '\n' ';')

	printf "id;${current_labels}\n" > "${csv_file}"
	grep . ${REPORT_LIST} | while read -r subj_procdir
	do
		run_and_log 1.extract_values extract_values "${subj_procdir}"
	done
done
