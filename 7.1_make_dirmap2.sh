# m.wyczalkowski 1000 dev
#DAT="dat/m.wyczalkowski.rawstat-1000.gz"
#OUT="dat/dirmap.m.wyczalkowski-1000.gz"

#DIRLIST="dat/m.wyczalkowski.1000.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.1000.filelist.tsv.gz"
DIRLIST="dat/m.wyczalkowski.20250121.dirlist.tsv.gz"
FILELIST="dat/m.wyczalkowski.20250121.filelist.tsv.gz"

OUT="dat/m.wyczalkowski.20250121.dirmap2.tsv"


python3 src/make_dir_map_tree.py -e $DIRLIST -f $FILELIST -o $OUT
