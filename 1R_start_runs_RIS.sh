source config.sh
# this provides OUTD, RUN_NAME, others

mkdir -p $OUTD

OUTFN="$OUTD/$RUN_NAME.rawstat.gz"

if [ -e $OUTFN ]; then
    >&2 echo ERROR: $OUTFN exists.  Delete if necessary
    exit 1
fi

>&2 echo Finding all files in $VOL_PATH
>&2 echo Writing to $OUTFN

BIN="bash src/stat_fs.sh" 
CMD="$BIN -o $OUTFN $VOL_PATH"

>&2 echo CMD= $CMD

eval $CMD
