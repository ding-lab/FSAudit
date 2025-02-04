# filter dirmap3
# retain only directories above a given size
# Write out data ready for input into dirtree


function filter_dirmap_10G {
    DAT=$1
    OUT=$2

    >&2 echo Reading $DAT 
    >&2 echo Writing $OUT
    LIM=10000000000 # 10G
    CAT="zcat"
    GZIP="gzip"
    COL="3"

#    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  grep -vf $X | $GZIP > $OUT
    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  $GZIP > $OUT
}

P="dinglab.20250121"
FILTER_LABEL="10G"
ULIST="dat/dinglab.20250121/dinglab.20250121.ownerlist.tsv"

while read L; do

    U=$(echo "$L" | cut -f 1)
    if [ $U == "owner_name" ]; then
        continue
    fi

    >&2 echo Processing user $U
    DAT="dat/$P/dirmap/$P.dirmap3-$U.tsv.gz"
    OUT="dat/$P/dirmap-filtered/$P.dirmap3-$U-$FILTER_LABEL.tsv.gz"

    filter_dirmap_10G $DAT $OUT

done < $ULIST

>&2 echo Written to $OUT
