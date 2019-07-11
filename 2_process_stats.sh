source FSAudit.config

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  

python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
