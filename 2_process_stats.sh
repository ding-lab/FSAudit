source FSAudit.config

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  

# This requires python 3
python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
