# Running docker on compute1
source config.sh

# docker pull amancevice/pandas:latest
#DOCKER="WUDocker/start_docker.sh"

#IMAGE="mwyczalkowski/python3-util:20250130"

# ask for 16Gb of memory
#ARGS="-m 16"

VOLS="/home/mwyczalk_test" 


##### CMD

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

# writes dat/$RUN_NAME/$RUN_NAME.dirmap3.tsv.gz
# also writes out dat/$RUN_NAME/$RUN_NAME.dirmap3-USER.tsv.gz files
mkdir -p "$OUTD/dirmap"
OUT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT_OWNER="$OUTD/$RUN_NAME.ownerlist.tsv"

ROOT="-R diskmnt"

CMD="python3 src/make_dir_map_tree.py $ROOT -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "

>&2 echo CMD = $CMD

### BSUB

#bash $DOCKER $ARGS -r -M compute1 -I $IMAGE -c "$CMD" $VOLS

# for testing, no CMD run
#bash $DOCKER $ARGS -r -M compute1 -I $IMAGE $VOLS


