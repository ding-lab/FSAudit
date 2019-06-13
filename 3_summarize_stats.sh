
DAT="dat/gc2737.processed.dat.gz"
OUT="dat/test.dat"

# May need to do `conda activate R
Rscript src/summarize_fs.R -Z $DAT $OUT

