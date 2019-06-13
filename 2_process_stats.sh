DAT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.gz"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.filestat.gz"
#OUT="dat/test.dat"

#python src/parse_fs.py -i $DAT -o $OUT
zcat $DAT | python src/parse_fs.py -o $OUT

echo Written to $OUT
