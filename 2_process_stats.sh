#DAT="dat/gc2737.1000.dat"
DAT="dat/home.dat.gz"
OUT="dat/home.filestat.gz"
#OUT="dat/test.dat"

python src/parse_fs.py -i $DAT -o $OUT

echo Written to $OUT
