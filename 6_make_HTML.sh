source config.sh

function make_dirtree {
    DAT=$1
    OUT=$2

    >&2 echo Reading $DAT, Writing to $OUT
    zcat $DAT | dirtree -o $OUT
}


## First make dirtree for the entire volume, showing all directories with >100Gb

>&2 echo Processing all entries
FILTER_LABEL="100G"
DAT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
HTML="$OUTD/html/$RUN_NAME.dirmap3-$FILTER_LABEL.html"
mkdir -p $OUTD/html
mkdir -p $OUTD/html/user

make_dirtree $DAT $HTML


## Next make dirtree per user, showing all directories with >10Gb owned by that user
FILTER_LABEL="10G"
ULIST="$OUTD/$RUN_NAME.ownerlist.tsv"


while read L; do
    U=$(echo "$L" | cut -f 1)
    if [ $U == "owner_name" ]; then
        continue
    fi

    >&2 echo Processing user $U
    DAT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.tsv.gz"
    HTML="$OUTD/html/user/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.html"
    make_dirtree $DAT $HTML
done < $ULIST

>&2 echo Written to $OUT
