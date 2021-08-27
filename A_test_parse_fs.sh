mkdir -p test
DAT="../dat/20210512.partial/MGI.gc2500.20210825.rawstat.gz"
OUT="test/MGI.gc2500.20210825.filestat.gz"

VOLUME_NAME="gc2500"
TIMESTAMP="20210825"

#CMD="python src/parse_fs.py $@ -i $DAT -o $OUT -V $VOLUME_NAME -T $TIMESTAMP"
CMD="python src/parse_fs.py $@ -i $DAT -o $OUT "
echo Running $CMD
eval $CMD
