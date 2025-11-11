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

PY="/home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/katmai.20251103/src/make_dir_map_tree.py"
CMD="python3 $PY $ROOT -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "

>&2 echo CMD = $CMD
#eval $CMD

### docker.  
# https://github.com/ding-lab/WUDocker.git

CMD_DOCKER="start_docker.sh $ARGS -r -M docker -I $IMAGE -c \"$CMD\" $VOLS"

echo CMD_DOCKER = $CMD_DOCKER
eval "$CMD_DOCKER"


