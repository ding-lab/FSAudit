mkdir -p test
DAT="dat/MGI.gc2500.20191001.filestat.gz"
OUT="test/MGI.gc2500.20191001.summary-test.dat"

# -g group.by: group by "owner_name", "ext", or "ext-owner_name" (default)
GROUP_BY="-g owner_name -V MGI.gc2500 "

# Also test these
# -a: append to out.dat rather than overwrite
# -H: skip header

CMD="Rscript src/summarize_fs.R $GROUP_BY -Z $DAT $OUT"
echo Running $CMD
eval $CMD
