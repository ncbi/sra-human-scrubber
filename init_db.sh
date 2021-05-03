#!/bin/bash
set -eu

curl -vf "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter.db" -o ./data/human_filter.db
exit 0
