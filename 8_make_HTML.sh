DAT="dat/m.wyczalkowski.20250121.rawstat-mod.gz"
OUT="html/m.wyczalkowski.20250121.1G.html"
X="dat/exclude.dat"

LIM=1000000000 # keep only dirs larger than 1G

gzcat $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 1 |  grep -vf $X | dirtree -o $OUT
