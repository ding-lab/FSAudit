# filter dirmap and make dirtree HTML file for the entire volume

# retain only directories above a given size
# Write out data ready for input into dirtree

source config.sh

function filter_dirmap {
    DAT=$1
    OUT=$2
    LIM=$3

    >&2 echo Reading $DAT 
    >&2 echo Writing $OUT
    CAT="zcat"
    GZIP="gzip"
    COL="3"

    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  $GZIP > $OUT
}

function make_dirtree {
    DAT=$1
    OUT=$2

    >&2 echo Reading $DAT, Writing to $OUT
    zcat $DAT | dirtree -o $OUT
}


# Process entire volume 
START=`date`
>&2 echo [$START] Processing entire volume
LIM=100000000000 # 100G
FILTER_LABEL="100G"

mkdir -p "$OUTD/dirmap-filtered"

DAT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
filter_dirmap $DAT $OUT $LIM

## Make dirtree for the entire volume, showing all directories with >100Gb

>&2 echo Processing all entries
DAT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
HTML="$OUTD/html/$RUN_NAME.dirmap3-$FILTER_LABEL.html"
mkdir -p $OUTD/html
mkdir -p $OUTD/html/user

make_dirtree $DAT $HTML

>&2 echo Written to $OUT and $HTML

END=`date`
>&2 echo Start time: $START
>&2 echo End time: $END
>&2 echo Written to $OUT
