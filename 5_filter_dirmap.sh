# filter dirmap3
# retain only directories above a given size
# Write out data ready for input into dirtree

source config.sh


RUN_NAME="$VOL_NAME.$DATESTAMP"
P=$RUN_NAME
OUTD="$OUTD_BASE/$RUN_NAME"

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

# Process entire volume (not per user)
START=`date`
>&2 echo [$START] Processing entire volume
LIM=100000000000 # 100G
FILTER_LABEL="100G"

# This assumes that dat is a link to /storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728
DATD="dat/dirmap"
OUTD="dat/dirmap-filtered"

mkdir -p $DATD
mkdir -p $OUTD

DAT="$DATD/$P.dirmap3.tsv.gz"
OUT="$OUTD/$P.dirmap3-$FILTER_LABEL.tsv.gz"
filter_dirmap $DAT $OUT $LIM


# Process volume per-user
LIM=10000000000 # 10G
FILTER_LABEL="10G"
ULIST="dat/$P.ownerlist.tsv"
while read L; do

    U=$(echo "$L" | cut -f 1)
    if [ $U == "owner_name" ]; then
        continue
    fi

    NOW=`date`
    >&2 echo [$NOW] Processing user $U
    DAT="$DATD/$P.dirmap3-$U.tsv.gz"
    OUT="$OUTD/$P.dirmap3-$U-$FILTER_LABEL.tsv.gz"
    LIM=10000000000 # 10G
    filter_dirmap $DAT $OUT $LIM

done < $ULIST

END=`date`
>&2 echo Start time: $START
>&2 echo End time: $END
>&2 echo Written to $OUT
