#!/bin/bash
set -eu

VERSION=$(curl "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter/current/version")
cd data && curl -vf "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter/${VERSION}.human_filter.db" -o "${VERSION}.human_filter.db"
ln -s "${VERSION}".human_filter.db human_filter.db
exit 0
