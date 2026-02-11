source config.sh

# run this on arches or katmai in a tmux container.  It runs itself in a docker container

# this works if not running in docker
# WUDocker/start_docker.sh -I mwyczalkowski/python3-util:20250130 /home/mwyczalk_test
# cd /home/mwyczalk_test/Projects/DataTracking/FSAudit/katmai.20251208
# bash K3_parse_dirs.sh

IMAGE="mwyczalkowski/python3-util:20250130"

VOLS="/home/mwyczalk_test" 

##### CMD

#ALT_RUN_NAME="katmai.20251103b"
#RUN_NAME=$ALT_RUN_NAME

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelistA.tsv.gz"

# DEV
#DEV_RUN_NAME="FLA-test"
#FILELIST="$PWD/tmp/FLA-debug.tsv.gz"
#DIRLIST="$PWD/tmp/${DEV_RUN_NAME}.dirlist.tsv.gz"
# /DEV

# writes dat/$RUN_NAME/$RUN_NAME.dirmap3.tsv.gz
# also writes out dat/$RUN_NAME/$RUN_NAME.dirmap3-USER.tsv.gz files
mkdir -p "$OUTD/dirmap"
OUT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT_OWNER="$OUTD/$RUN_NAME.ownerlist.tsv"

ROOT="-R root -r"

PY="$PWD/src/make_dir_map_tree.py"
CMD="python3 $PY $ROOT -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "

>&2 echo CMD = $CMD
#eval $CMD

#exit

### docker.  
# https://github.com/ding-lab/WUDocker.git

CMD_DOCKER="bash WUDocker/start_docker.sh $ARGS -r -M docker -I $IMAGE -c \"$CMD\" $VOLS"

echo CMD_DOCKER = $CMD_DOCKER
eval "$CMD_DOCKER"


