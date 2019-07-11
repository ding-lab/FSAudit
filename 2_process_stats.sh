TIMESTAMP="20190708"
VOLNAME="cptac3_scratch" # short name

DATD="/diskmnt/Projects/cptac_scratch/FSAudit/dat"

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  

python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
