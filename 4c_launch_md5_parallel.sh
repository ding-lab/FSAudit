OUTD="/home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20250916"
LIST="$OUTD/katmai.20250916.md5-worklist.tsv.gz"

OUT="$OUTD/katmai.20250916.md5-raw.tsv"

>&2 echo Reading $LIST
>&2 echo Writing $OUT
date

zcat $LIST | tail -n +2 | cut -f 1 | xargs -I "{}" -n 1 -P 5 md5sum "{}" > $OUT

date
