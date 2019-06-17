TIMESTAMP="20190615"
DAT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.${TIMESTAMP}.rawstat.gz"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.${TIMESTAMP}.filestat.gz"

python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
