source config.sh

#FILELIST="$OUTD/${RUN_NAME}.filelist.tsv.gz"
FILELIST="dev-data/dat/BIG100.filelist.tsv.gz"

if [ ! -e $PAST_MD5 ]; then
    >&2 echo ERROR: PAST_MD5 $PAST_MD5 does not exist
    exit 1
fi

#OUTD="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dev/FSAudit-md5"
OUT="$OUTD/${RUN_NAME}.md5-worklist.tsv"

CMD="python3 src/make_md5_worklist.py -m $PAST_MD5 -o $OUT $FILELIST"

>&2 echo RUNNING: $CMD

eval $CMD
