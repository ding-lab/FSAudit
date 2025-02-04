
function make_dirtree {
    DAT=$1
    OUT=$2

    >&2 echo Reading $DAT, Writing to $OUT
    gzcat $DAT | dirtree -o $OUT
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
    DAT="dat/$P/dirmap-filtered/$P.dirmap3-$U-$FILTER_LABEL.tsv.gz"
    HTML="dat/$P/html/$P.dirmap3-$U-$FILTER_LABEL.html"

    make_dirtree $DAT $HTML

done < $ULIST

>&2 echo Written to $OUT
