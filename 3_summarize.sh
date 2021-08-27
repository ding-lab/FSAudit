mkdir -p test
DATD="/gscmnt/gc2508/dinglab/mwyczalk/FSAudit/dat/20210825"
OUT="test/summary-20210825.dat"
mkdir -p test

CMD="python src/summarize_fs.py -o $OUT $DATD/*.filestat.gz "
echo Running $CMD
eval $CMD
