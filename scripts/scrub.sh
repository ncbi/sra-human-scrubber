#!/bin/bash
set -euo pipefail

#Usage help
usage() {
    printf "Usage: scrub.sh [OPTIONS] [file.fastq] \n"
    printf "OPTIONS:\n"
    printf "\t-i <input_file>; Input Fastq File.\n"
    printf "\t-o <output_file>; Save cleaned sequence reads to file, or set to "-" for stdout.\n"
    printf "\t\tNOTE: When stdin is used, output is stdout by default.\n"
    printf "\t-p <number> Number of threads to use.\n"
    printf "\t-d <database_path>; Specify a database other than default to use.\n"
    printf "\t-x ; Remove spots instead of default 'N' replacement.\n"
    printf "\t\tNOTE: Now by default sequence length of identified spots replaced with 'N'.\n"
    printf "\t-r ; Save identified spots to <input_file>.spots_removed.\n"
    printf "\t-u <user_named_file>; Save identified spots to <user_named_file>.\n"
    printf "\t\tNOTE: Required with -r if output is stdout, otherwise optional.\n"
    printf "\t-t ; Run test.\n"
    printf "\t-s ; Input is (collated) interleaved paired-end(read) file AND you wish both reads masked or removed.\n"
    printf "\t-h ; Display this message.\n\n"
    exit 0;
}

#Initalize vars
INFILE=
OUTFILE=
REPLACEN="-n" #default is now to replace with N
SAVEIDSPOTS=
BADSPOTFILE=
RUNTEST=false
THREADS=
INTERLEAVED=
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  >/dev/null 2>&1 && pwd  )"
ROOT=$(dirname $DIR)
DB=$ROOT/data/human_filter.db

#Get input
while getopts ":i:o:d:p:u:hxrts" opts; do
    case $opts in
        i) INFILE=${OPTARG}
            ;;
        o) OUTFILE=${OPTARG}
            ;;
        d) DB=${OPTARG}
            ;;
        p) THREADS=${OPTARG}
            ;;
        x) REPLACEN="" # now default is on, this is to turn off
            ;;
        r) SAVEIDSPOTS="-r"
            ;;
        u) BADSPOTFILE=${OPTARG} && SAVEIDSPOTS="-r"
            ;;
        s) INTERLEAVED="-I"
            ;;
        t) RUNTEST=true
            ;;
        h | *) usage
            ;;
    esac
done

#Check for no args
[ "$#" == 0 ]  &&  [ -t 0 ]  && usage

if [ ! -e "${INFILE}" ]  && [[ "${@:$#}" == "test" || -t 0 ]];
  then
    INFILE="${@:$#}"
fi

if [ "$INFILE" == "test" ];
   then
     RUNTEST=true
fi

#TESTING create temp dir and set infile
if $RUNTEST && [ -e "$ROOT/test/scrubber_test.fastq" ];
  then
    TMP_DIR=$(mktemp -d)
    cp "$ROOT"/test/* "$TMP_DIR/"
    INFILE=$TMP_DIR/scrubber_test.fastq
fi

if [ ! "${OUTFILE}" ] && [ "${INFILE}" ];
   then 
     OUTFILE="$INFILE.clean"
fi

#Create temp fastq if reading from stdin
TMP_F_DIR=$(mktemp -d)
if [ ! -e "${INFILE}" ];
  then
    tee  > "$TMP_F_DIR/temp.fastq"
    INFILE="$TMP_F_DIR/temp.fastq"
fi
#Use infile or temp fastq and generate fasta
"$ROOT/scripts/fastq_to_fasta.py" ${INTERLEAVED} < "${INFILE}" > "$TMP_F_DIR/temp.fasta"

if [ "$OUTFILE" ] && [ "$OUTFILE" != "-" ];
  then
    "${ROOT}"/bin/aligns_to -db "${DB}" $(if [[ "$THREADS" =~ ^[0-9]+$ ]]; then printf "%s" "-num_threads $THREADS"; fi) "$TMP_F_DIR/temp.fasta" \
     | "$ROOT/scripts/cut_spots_fastq.py" "$INFILE" "$REPLACEN" "$SAVEIDSPOTS" "$BADSPOTFILE"  ${INTERLEAVED} > "$OUTFILE"
    if [ "$SAVEIDSPOTS" ] && [ -e "$TMP_F_DIR/temp.fastq.removed_spots" ];
      then
        cp "$TMP_F_DIR/temp.fastq.removed_spots" "$OUTFILE.removed_spots"
    fi
    else
      "${ROOT}"/bin/aligns_to -db "${DB}" $(if [[ "$THREADS" =~ ^[0-9]+$ ]]; then printf "%s" "-num_threads $THREADS"; fi) "$TMP_F_DIR/temp.fasta" \
      | "$ROOT/scripts/cut_spots_fastq.py" "$INFILE" "$REPLACEN" "$SAVEIDSPOTS" "$BADSPOTFILE" ${INTERLEAVED}
fi

#Check if TESTING was successful
if $RUNTEST;
  then
    if [ -L "${DB}" ] &&  which readlink > /dev/null 2>&1
      then
        f=$(readlink "${DB}")
        if [[ $f =~ human_filter.db.[0-9]* ]]
          then
            echo "DB version is ${f##human_filter.db.}"
        elif [[ $f =~ [0-9]*.human_filter.db ]]
          then
            echo "DB version is ${f%%.human_filter.db}"
        fi
    fi
    if [ -e "$TMP_DIR/scrubber_test.fastq.clean" ] &&
     [ -n "$(diff "$TMP_DIR/scrubber_test.fastq.clean" "$TMP_DIR/scrubber_expected_output.fastq")" ]
      then
        echo "test failed!"
        rm -rf "$TMP_DIR"
        exit 1
    fi
    printf "\ntest succeeded\n\n"
    rm -rf "$TMP_DIR"
fi

#Clean up temp files
if [ -e "$TMP_F_DIR" ];
    then
    rm -rf "$TMP_F_DIR"
fi
exit 0
