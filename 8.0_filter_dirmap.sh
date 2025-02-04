# filter dirmap3
# retain only directories above a given size
# Write out data ready for input into dirtree


function filter_dirmap_10G {
    DAT=$1
    OUT=$1

    LIM=10 000 000 000 # 10G
    CAT="gzcat"
    GZIP="gzip"
    COL="3"

#    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  grep -vf $X | $GZIP > $OUT
    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  $GZIP > $OUT
}

#DATASET="1000dev"
#DATASET="mw"  # full m.wyczalkowski dataset
#DATASET="dinglab"  # full dinglab dataset
DATASET="dinglab-mwycz"  # full dinglab dataset


if [[ "$DATASET" == "1000dev" ]]; then
    # 1000 dev data
    DAT="dat/m.wyczalkowski.1000.dirmap2.tsv"
    OUT="html/test-1000.dirmap2-filtered.tsv"
    X="dat/none.dat"
    LIM=0
    CAT="cat"
    COL="3"     # this is the one with size labels
elif [[ $DATASET == "mw" ]]; then
#    # complete m.wyczalkowski dataset
    DAT="dat/m.wyczalkowski.20250121.dirmap3.tsv.gz"
    OUT="dat/m.wyczalkowski.20250121.dirmap3-1G.tsv"
    X="dat/exclude.dat"
    LIM=1000000000 # 1G
    CAT="gzcat"
    GZIP="cat"  # if we don't want compression
    COL="3"
elif [[ $DATASET == "dinglab" ]]; then
#    # complete m.wyczalkowski dataset
    DAT="dat/dinglab.20250121.dirmap3.tsv.gz"
    OUT="dat/dinglab.20250121.dirmap3-100G.tsv.gz"
    X="dat/none.dat"
    LIM=100000000000 # 100G
    CAT="zcat"
    GZIP="gzip"
    COL="3"
elif [[ $DATASET == "dinglab-mwycz" ]]; then
#    # complete m.wyczalkowski dataset
fi


DAT="dat/dinglab.20250121/dinglab.20250121.dirmap3-songcao.tsv.gz"
OUT="dat/dinglab.20250121/dinglab.20250121.dirmap3-songcao-10G.tsv.gz"
#gzcat $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | wc -l

>&2 echo Written to $OUT
