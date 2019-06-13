
#DAT="dat/gc2737.processed.dat.gz"
DAT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.filestat.gz"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.summary.dat"

# May need to do `conda activate R
Rscript src/summarize_fs.R -Z $DAT $OUT

