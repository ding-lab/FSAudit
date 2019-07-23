source FSAudit.config

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  

# This requires python 3.  Python 2 yields errors like this:
#   TypeError: open() got an unexpected keyword argument 'encoding'

python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
