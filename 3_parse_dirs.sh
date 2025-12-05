# Running docker on compute1
source config.sh

# docker pull amancevice/pandas:latest
DOCKER="WUDocker/start_docker.sh"

# https://biocontainers.pro/tools/python3-biopython
# IMAGE="python:3.12-slim-bookworm"
IMAGE="mwyczalkowski/python3-util:20250130"

# ask for 16Gb of memory
# 8/5/25 - 16Gb not landing, so running default for now
ARGS="-m 16"

VOLS="/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski/Active/ProjectStorage"



##### CMD

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

#DIRLIST="dev-dat/DEV-1000.dirlist.tsv.gz"
#FILELIST="dev-dat/filelist-1000.tsv.gz"
#FILELIST="dev-dat/filelist-short-primary.tsv.gz"

# writes dat/$RUN_NAME/$RUN_NAME.dirmap3.tsv.gz
# also writes out dat/$RUN_NAME/$RUN_NAME.dirmap3-USER.tsv.gz files
mkdir -p "$OUTD/dirmap"
OUT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT_OWNER="$OUTD/$RUN_NAME.ownerlist.tsv"

ROOT="-R storage1"

EXCLUDE_PRIMARY="-p"

CMD="python3 src/make_dir_map_tree.py $EXCLUDE_PRIMARY -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT $ROOT"

>&2 echo CMD = $CMD

#eval $CMD


### BSUB

#bash $DOCKER $ARGS -r -M compute1 -I $IMAGE -c "$CMD" $VOLS

# for testing, no CMD run
#bash $DOCKER $ARGS -r -M compute1 -I $IMAGE $VOLS
