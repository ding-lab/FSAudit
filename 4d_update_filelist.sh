# update filelist with newly calculated md5 values

source config.sh

MD5="$OUTD/${RUN_NAME}.md5-raw.txt"
FL_OLD="$OUTD/${RUN_NAME}.filelistA.tsv.gz"
FL_NEW="$OUTD/${RUN_NAME}.filelistB.tsv.gz"

>&2 echo Reading filelist $FL_OLD
>&2 echo Reading MD5 results $MD5
>&2 echo Writing filelist $FL_NEW

CMD="python3 src/update_filelist.py -m $MD5 $FL_OLD | gzip > $FL_NEW"

>&2 echo Running: $CMD
date

eval $CMD

date
>&2 echo Written to $OUT
