source config.sh

RUN_NAME="$VOL_NAME.$DATESTAMP"
OUTD="$OUTD_BASE/$RUN_NAME"

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

#OUTD="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728/dev"
#DIRLIST="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728/dev/dirlist-1000.tsv.gz"
#FILELIST="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728/dev/filelist-1000.tsv.gz"

# writes dat/$RUN_NAME/$RUN_NAME.dirmap3.tsv.gz
# also writes out dat/$RUN_NAME/$RUN_NAME.dirmap3-USER.tsv.gz files
mkdir -p "$OUTD/dirmap"
OUT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT_OWNER="$OUTD/$RUN_NAME.ownerlist.tsv"

CMD="python3 src/make_dir_map_tree.py -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "

echo $CMD

