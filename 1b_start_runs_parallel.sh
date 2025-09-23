source config.sh
# this provides OUTD, RUN_NAME, others

mkdir -p $OUTD

#OUTFN="$OUTD/$RUN_NAME.rawstat.gz"
LOGD="$OUTD/log"
DATD="$OUTD/dat"

# VL="../dat/VolumeList-C.dat"  # C is complete list
VL="../dat/VolumeList-D.dat"  # D is subset of C for restart

>&2 echo Finding all files in $VOL_PATH
>&2 echo Writing to $OUTFN

BIN="bash src/parallel_stat_fs.sh"
CMD="$BIN $@ -J 5 -l $LOGD -t $DATD -I $VL "

>&2 echo CMD= $CMD
eval $CMD

