DATD="/home/m.wyczalkowski/Projects/FSAudit/FSAudit/dat-noclobber"
OUT="dat/summary-20250121.dat"

CMD="python3 src/summarize_fs.py -o $OUT $DATD/*.filestat.gz "
echo Running $CMD
eval $CMD
