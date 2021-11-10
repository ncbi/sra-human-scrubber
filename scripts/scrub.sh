#!/bin/bash
set -eu

#Usage help
usage() {
    printf "Usage: scrub.sh [OPTIONS] [file.fastq] \n"
    printf "OPTIONS:\n"
    printf "\t-i <input_file>; Input Fastq File\n"
    printf "\t-o <output_file>; Save cleaned sequence reads to file, or set to "-" for stdout.\n"
    printf "\t\tNOTE: When stdin is used, output is stdout by default.\n"
    printf "\t-d <database_path>; Specify path to custom database file (e.g. human_filter.db).\n"
    printf "\t-n ; Replace sequence length of identified spots with 'N'\n"
    printf "\t-r ; Save identified spots to file.fastq.spots_removed\n"
    printf "\t-h ; Display this message\n\n"
    exit 0;
}

#Initalize vars
INFILE=
OUTFILE=
REPLACEN=
SAVEIDSPOTS=
RUNTEST=false
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  >/dev/null 2>&1 && pwd  )"
ROOT=$(dirname $DIR)
DB=$ROOT/data/human_filter.db

#Get input
while getopts ":i:o:d:hnrt" opts; do
    case $opts in
        i) INFILE=${OPTARG}
            ;;
        o) OUTFILE=${OPTARG}
            ;;
        d) DB=${OPTARG}
            ;;
        n) REPLACEN=" -n "
            ;;
        r) SAVEIDSPOTS=" -r "
            ;;
        t) RUNTEST=true
            ;;
        h | *) usage
            ;;
    esac
done

#Check for empty stdin and no args
[ -t 0 ] && [ $# == 0 ] && usage

if [ ! -e "${INFILE}" ] && [ -t 0 ] && [ -e "${@:$#}" ];
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

if [ ! "${OUTFILE}" ] && [ -t 0 ];
   then 
     OUTFILE="$INFILE.clean"
fi

#Convert to FASTA, create temp fastq if reading from stdin
TMP_F_DIR=$(mktemp -d)
if [ -t 0 ];
  then
    python "$ROOT/scripts/fastq_to_fasta.py" < "${INFILE}" > "$TMP_F_DIR/temp.fasta"
elif [ ! -t 0 ];
  then
    tee "$TMP_F_DIR/temp.fastq" | python "$ROOT/scripts/fastq_to_fasta.py" > "$TMP_F_DIR/temp.fasta"
fi

#Use infile or temp fastq and either send output to stdout or specified fasta
if [ "$OUTFILE" ] && [ "$OUTFILE" != "-" ];
  then
    ${ROOT}/bin/aligns_to -db "${DB}" "$TMP_F_DIR/temp.fasta" | "$ROOT/scripts/cut_spots_fastq.py" $(if [ $INFILE ]; then echo "${INFILE}";else echo "$TMP_F_DIR/temp.fastq";fi) $REPLACEN $SAVEIDSPOTS > $OUTFILE
    if [ $SAVEIDSPOTS ] && [ -e "$TMP_F_DIR/temp.fastq.removed_spots" ];
        then
          cp "$TMP_F_DIR/temp.fastq.removed_spots" "$OUTFILE.removed_spots"
    fi
else
    ${ROOT}/bin/aligns_to -db "${DB}" "$TMP_F_DIR/temp.fasta" | "$ROOT/scripts/cut_spots_fastq.py" $(if [ $INFILE ]; then echo "${INFILE}";else echo "$TMP_F_DIR/temp.fastq";fi) $REPLACEN
fi

#Check if TESTING was successful
if $RUNTEST;
  then
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
