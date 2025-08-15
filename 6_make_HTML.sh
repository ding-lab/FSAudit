source config.sh
RUN_NAME="$VOL_NAME.$DATESTAMP"
P=$RUN_NAME
OUTD="$OUTD_BASE/$RUN_NAME"

function make_dirtree {
    DAT=$1
    OUT=$2

    >&2 echo Reading $DAT, Writing to $OUT
    zcat $DAT | dirtree -o $OUT
}


>&2 echo Processing all entries
FILTER_LABEL="100G"
DAT="dat/dirmap-filtered/$P.dirmap3-$FILTER_LABEL.tsv.gz"
HTML="dat/html/$P.dirmap3-$FILTER_LABEL.html"
mkdir -p dat/html
make_dirtree $DAT $HTML


FILTER_LABEL="10G"
ULIST="dat/$P.ownerlist.tsv"

while read L; do

    U=$(echo "$L" | cut -f 1)
    if [ $U == "owner_name" ]; then
        continue
    fi

    >&2 echo Processing user $U
    DAT="dat/dirmap-filtered/$P.dirmap3-$U-$FILTER_LABEL.tsv.gz"
    HTML="dat/html/$P.dirmap3-$U-$FILTER_LABEL.html"
    make_dirtree $DAT $HTML

done < $ULIST

>&2 echo Written to $OUT
