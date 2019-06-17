TIMESTAMP="20190615"
DAT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.${TIMESTAMP}.filestat.gz"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.${TIMESTAMP}.summary.dat"

# May need to do `conda activate R
Rscript src/summarize_fs.R -Z $DAT $OUT

