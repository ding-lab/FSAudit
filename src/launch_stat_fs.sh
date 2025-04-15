VOL_NAME=$1              # e.g. dinglab
VOL_PATH=$2         # e.g. /storage1/fs1/dinglab/Active
DATESTAMP=$3        # e.g. 20250401
#OUT_BASE="/scratch1/fs1/dinglab/m.wyczalkowski/FSAudit/dat"
OUT_BASE=$4

RUN_NAME="$VOL_NAME.$DATESTAMP"
OUTD="$OUT_BASE/$RUN_NAME"
mkdir -p $OUTD


OUTFN="$OUTD/$RUN_NAME.rawstat.gz"

>&2 echo Finding all files in $VOL_PATH
>&2 echo Writing to $OUTFN

BIN="bash src/stat_fs.sh" 
CMD="$BIN -o $OUTFN $VOL_PATH"

###
DOCKER_BIN="WUDocker/start_docker.sh"

# LSF group
LSFG="-g /m.wyczalkowski/wgs_coverage"

IMAGE="mwyczalkowski/python3-util:20250130" # we don't really use python here but this works
MAPPED_VOLS="$OUT_BASE $VOL_PATH"

DOCKER_CMD="bash $DOCKER_BIN -g \"$LSFG\" -r -M compute1 -R $RUN_NAME -I $IMAGE -c \"$CMD\" $MAPPED_VOLS"

>&2 echo Running: $DOCKER_CMD
eval "$DOCKER_CMD"

