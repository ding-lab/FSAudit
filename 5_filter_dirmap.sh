# filter dirmap3
# retain only directories above a given size
# Write out data ready for input into dirtree

# This is done for both the entire volume and for the volume per user.
# This step is then followed by step 6 for each dataset
# Suggest to combine these, so that one step is filter + dirtree for the volume,
# and next step is filter + dirtree per user

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

# Process entire volume (not per user)
START=`date`
>&2 echo [$START] Processing entire volume
LIM=100000000000 # 100G
FILTER_LABEL="100G"

mkdir -p "$OUTD/dirmap-filtered"

DAT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
OUT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
filter_dirmap $DAT $OUT $LIM

# Process volume per-user
LIM=10000000000 # 10G
FILTER_LABEL="10G"
ULIST="dat/$RUN_NAME.ownerlist.tsv"
while read L; do

    U=$(echo "$L" | cut -f 1)
    if [ $U == "owner_name" ]; then
        continue
    fi

    NOW=`date`
    >&2 echo [$NOW] Processing user $U
    DAT="$OUTD/dirmap/$RUN_NAME.dirmap3-$U.tsv.gz"
    OUT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.tsv.gz"
    LIM=10000000000 # 10G
    filter_dirmap $DAT $OUT $LIM

done < $ULIST

END=`date`
>&2 echo Start time: $START
>&2 echo End time: $END
>&2 echo Written to $OUT
