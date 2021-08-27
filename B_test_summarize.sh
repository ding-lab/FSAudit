mkdir -p test
DAT="test/gc2500.20210825.filestat.gz test/gc2508.20210825.filestat.gz test/gc2509.20210825.filestat.gz"
OUT="test/summary.dat"

#CMD="python src/parse_fs.py $@ -i $DAT -o $OUT -V $VOLUME_NAME -T $TIMESTAMP"
CMD="python src/summarize_fs.py -o $OUT $DAT "
echo Running $CMD
eval $CMD
