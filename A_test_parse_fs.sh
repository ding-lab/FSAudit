TIMESTAMP="20210825"

function process {
    VOLUME_NAME=$1
    DAT="../dat/20210512.partial/MGI.$VOLUME_NAME.$TIMESTAMP.rawstat.gz"
    OUT="test/$VOLUME_NAME.$TIMESTAMP.filestat.gz"

    CMD="python src/parse_fs.py $@ -i $DAT -o $OUT -V $VOLUME_NAME -T $TIMESTAMP"
    echo Running $CMD
    eval $CMD
}


mkdir -p test
process gc2500
process gc2508
process gc2509
