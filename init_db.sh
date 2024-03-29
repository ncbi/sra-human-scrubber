#!/bin/bash
set -eu
# logic: if the new db is here, do nothing
# if the old db (named human_filter.db) exists and is not a link, remove and proceed
# if the new db is not here, then check for symbolic link, unlink if needed and proceed.

VERSION=$(curl -f "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter/current/version.txt")
[[ -z "$VERSION" ]] && echo "Version  not retrieved." && exit 1
MD5=$(curl -f "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter/human_filter.db.${VERSION}.md5")
[[ -z "$MD5" ]] && echo " MD5 not retrieved." && exit 2
if [ -e "data/${VERSION}.human_filter.db" ] && [ -L "data/human_filter.db" ];
  then
    current_md5=$(md5sum "data/${VERSION}.human_filter.db" | cut -d ' ' -f1)
elif  [ -e "data/human_filter.db.${VERSION}" ] && [ -L "data/human_filter.db" ];
  then
    current_md5=$(md5sum "data/human_filter.db.${VERSION}" | cut -d ' ' -f1)
else
  current_md5=0
fi

if  [ "$current_md5" != "$MD5" ];
  then
    curl -f "https://ftp.ncbi.nlm.nih.gov/sra/dbs/human_filter/human_filter.db.${VERSION}" -o "data/human_filter.db.${VERSION}"
    my_md5=$(md5sum "data/human_filter.db.${VERSION}" | cut -d ' ' -f1)
    if [ "$my_md5" == "$MD5" ];
      then
        cd data
        [[ -e "human_filter.db" ]] && rm "human_filter.db"
        ln -s  "human_filter.db.${VERSION}" "human_filter.db"
        echo "Successfully installed human_filter.db.${VERSION}."
        echo "You may want to delete a previous human_filter db to econoimize disk space."
    else
      echo "my_md5 was $my_md5, but should be $MD5"
      exit 3
    fi
else
    echo "Existing database is up to date."
fi
