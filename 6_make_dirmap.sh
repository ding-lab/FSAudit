DAT="dat/raw-1000.tsv"
OUT="dat/dirmap-1000.tsv"
#DAT="dat/raw-1M.tsv.gz"
#OUT="dat/dirmap-m.wyczalkowski-1M-L.tsv"

python3 src/make_dir_map.py -i $DAT -o $OUT
