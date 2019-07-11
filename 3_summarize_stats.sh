TIMESTAMP="20190708"
VOLNAME="cptac3_scratch" # short name
DATD="/diskmnt/Projects/cptac_scratch/FSAudit/dat"

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.summary.dat"  

# May need to do `conda activate R
Rscript src/summarize_fs.R -Z $DAT $OUT

