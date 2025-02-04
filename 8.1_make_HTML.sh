U="songcao"
DAT="dat/dinglab.20250121/dinglab.20250121.dirmap3-$U-10G.tsv.gz"
OUT="dat/dinglab.20250121/dinglab.20250121.dirmap3-$U-10G.html"
#OUT="html/dinglab.20250121.dirtree-100G.html"

gzcat $DAT |  dirtree -o $OUT

>&2 echo Written to $OUT
