source config.sh
# this provides OUTD, RUN_NAME, others

NCPU=10

mkdir -p $OUTD

#OUTFN="$OUTD/$RUN_NAME.rawstat.gz"
LOGD="$OUTD/log"
DATD="$OUTD/dat"

VL="../VolumeList/VolumeList-C2.dat"  # C is most current list of 20251103

>&2 echo Finding all files in $VOL_PATH
>&2 echo Writing to $OUTFN

BIN="bash src/parallel_stat_fs.sh"
CMD="$BIN $@ -J $NCPU -l $LOGD -t $DATD -I $VL "

>&2 echo CMD= $CMD
eval $CMD

