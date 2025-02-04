# m.wyczalkowski
#DAT="dat/m.wyczalkowski.20250121.rawstat-mod.gz"
#OUT="dat/dirmap.m.wyczalkowski.20250121-all.tsv"

# m.wyczalkowski 1000 dev
#DAT="dat/m.wyczalkowski.rawstat-1000.gz"
#OUT="dat/dirmap.m.wyczalkowski-1000.gz"


# dinglab
DAT="dat/dinglab.20250121.rawstat-mod.gz"
OUT="dat/dirmap.dinglab.20250121-all.tsv"

time python3 src/make_dir_map.py -i $DAT -o $OUT
