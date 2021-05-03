#!/bin/bash
set -eu

fastq="$1"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  >/dev/null 2>&1 && pwd  )"
ROOT=$(dirname $DIR)
DB=$ROOT/data/human_filter.db
if [ "$1" == "test" ] && [ -e "$ROOT/test/scrubber_test.fastq" ];
  then
    TMP_DIR=$(mktemp -d)
    cp "$ROOT"/test/* "$TMP_DIR/"
    fastq=$TMP_DIR/scrubber_test.fastq
fi
python "$ROOT/scripts/fastq_to_fasta.py" < "$fastq" > "$fastq.fasta"
${ROOT}/bin/aligns_to -db "$ROOT/data/human_filter.db" "$fastq.fasta" | "$ROOT/scripts/cut_spots_fastq.py" "$fastq" > "$fastq.clean"
if [ "$1" == "test" ];
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




