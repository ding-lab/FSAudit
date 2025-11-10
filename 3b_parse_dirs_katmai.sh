source config.sh


# this works
# start_docker.sh -I mwyczalkowski/python3-util:20250130 /home/mwyczalk_test
# cd /home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/katmai.20251103
# bash 3b_parse_dirs_katmai.sh

IMAGE="mwyczalkowski/python3-util:20250130"

VOLS="/home/mwyczalk_test" 

##### CMD

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

# writes dat/$RUN_NAME/$RUN_NAME.dirmap3.tsv.gz
# also writes out dat/$RUN_NAME/$RUN_NAME.dirmap3-USER.tsv.gz files
mkdir -p "$OUTD/dirmap"
OUT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT_OWNER="$OUTD/$RUN_NAME.ownerlist.tsv"

ROOT="-R root -r"

CMD="python3 src/make_dir_map_tree.py $ROOT -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "

>&2 echo CMD = $CMD
eval $CMD

### docker.  Not being currently done, but develop this

#bash $DOCKER $ARGS -r -M compute1 -I $IMAGE -c "$CMD" $VOLS


