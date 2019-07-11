source FSAudit.config

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.summary.dat"  

# May need to do `conda activate R
Rscript src/summarize_fs.R -Z $DAT $OUT

