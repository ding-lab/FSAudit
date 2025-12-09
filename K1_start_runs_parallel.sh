source config.sh
# this provides OUTD, RUN_NAME, others

NCPU=10


LOGD="$OUTD/log"
DATD="$OUTD/raw"
mkdir -p $LOGD
mkdir -p $DATD

VL="../VolumeList/VolumeList-C2.dat"

>&2 echo Finding all files in $VL
>&2 echo Writing to $OUTD

BIN="bash src/parallel_stat_fs.sh"
CMD="$BIN $@ -J $NCPU -l $LOGD -t $DATD -I $VL "

>&2 echo CMD= $CMD
>&2 echo Does this have to be run as sudo?
#eval $CMD


