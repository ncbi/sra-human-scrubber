#!/bin/bash
set -eu

OPTS=""
GZIP=""
# now offer -h for usage, -n for NN, -r for saving identified spots

usage() {
    printf "Usage: scrub.sh [OPTIONS] file.fastq\n"
    printf "OPTIONS:\n"
    printf "\t-n ; Replace sequence length of identified spots with 'N'\n"
    printf "\t-r ; Save identified spots to file.fastq.spots_removed\n"
    printf "\t-z ; Input FASTQ is compressed with GZip\n"
    printf "\t-h ; Display this message\n\n"
    exit 0;
}
[ $# -eq 0 ] || [ "${1}" == "-h" ] && usage
while getopts "hnr" opts; do
    case $opts in
        n) OPTS+=" -n "
            ;;
        r) OPTS+=" -r "
            ;;
        z) OPTS+=" -z " ; GZIP="1"
            ;;
        h) usage
           exit 0
            ;;
    esac
done
shift $((OPTIND-1))
fastq="$1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  >/dev/null 2>&1 && pwd  )"
ROOT=$(dirname $DIR)
DB=$ROOT/data/human_filter.db

if [ "$1" == "test" ] && [ -e "$ROOT/test/scrubber_test.fastq" ];
  then
    TMP_DIR=$(mktemp -d)
    cp "$ROOT"/test/* "$TMP_DIR/"
    fastq=$TMP_DIR/scrubber_test.fastq
elif [ "$1" == "test_gz" ] && [ -e "$ROOT/test/scrubber_test.fastq.gz" ];
  then
    TMP_DIR=$(mktemp -d)
    cp "$ROOT"/test/* "$TMP_DIR/"
    fastq=$TMP_DIR/scrubber_test.fastq.gz
    GZIP="1"
    OPTS+=" -z "
fi

if [ "${GZIP}" == "1" ]; then 
  zcat $fastq | python "$ROOT/scripts/fastq_to_fasta.py" > "$fastq.fasta"
else
  python "$ROOT/scripts/fastq_to_fasta.py" < "$fastq" > "$fastq.fasta"
fi
${ROOT}/bin/aligns_to -db "$ROOT/data/human_filter.db" "$fastq.fasta" | "$ROOT/scripts/cut_spots_fastq.py" "$fastq" ${OPTS} > "$fastq.clean"
if [ "$1" == "test" ] ||  [ "$1" == "test_gz" ] ;
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
else
  rm -f "$fastq.fasta"
fi
exit 0
