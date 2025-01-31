# 1000 dev data
DAT="dat/m.wyczalkowski.1000.dirmap2.tsv"
OUT="html/test-1000.html"
X="dat/none.dat"
LIM=0
CAT="cat"
COL="3"     # this is the one with size labels

# real data
#DAT="dat/m.wyczalkowski.20250121.dirmap2.tsv.gz"
#OUT="html/test-1000.html"
#X="dat/exclude.dat"
#LIM=1000000000 # 1G
#CAT="gzcat"
#COL="3"

$CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  grep -vf $X | dirtree -o $OUT

#gzcat $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | wc -l

>&2 echo Written to $OUT
