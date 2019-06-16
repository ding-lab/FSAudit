DAT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.rawstat.gz"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.filestat.gz"

python src/parse_fs.py -i $DAT  -o $OUT

echo Written to $OUT
