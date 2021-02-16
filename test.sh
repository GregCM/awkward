#!/bin/sh

#1) SH
#shellcheck -s sh kjv.sh

#2) TSV
gunzip kjv.tsv.gz
if [ $(spell kjv.tsv | wc -l) = 3884 ]; then
    echo "No problems here!"
    gzip kjv.tsv
    exit 0
else
    echo "Your bible has been corrupted!"
    gzip kjv.tsv
    exit 1
fi
