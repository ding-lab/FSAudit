source config.sh
# this provides OUTD, RUN_NAME, others

# Note: suggest to run from tmux container (not bsub) for dinglab runs
USE_BSUB=0

mkdir -p $OUTD

OUTFN="$OUTD/raw/$RUN_NAME.rawstat.gz"

if [ -e $OUTFN ]; then
    >&2 echo ERROR: $OUTFN exists.  Delete if necessary
    exit 1
fi

>&2 echo Finding all files in $VOL_PATH
>&2 echo Writing to $OUTFN

BIN="bash src/stat_fs.sh" 
CMD="$BIN -o $OUTFN $VOL_PATH"

>&2 echo CMD= $CMD


if [ "$USE_BSUB" == 1 ]; then
    DOCKER_BIN="WUDocker/start_docker.sh"

    # LSF group
    LSFG="-g /m.wyczalkowski/wgs_coverage"

    IMAGE="mwyczalkowski/python3-util:20250130" # we don't really use python here but this works
    MAPPED_VOLS="$OUT_BASE $VOL_PATH"

    DOCKER_CMD="bash $DOCKER_BIN -g \"$LSFG\" -r -M compute1 -R $RUN_NAME -I $IMAGE -c \"$CMD\" $MAPPED_VOLS"

    >&2 echo Running: $DOCKER_CMD
    eval "$DOCKER_CMD"
else
    eval $CMD
fi
