# m.wyczalkowski 1000 dev
#DAT="dat/m.wyczalkowski.rawstat-1000.gz"
#OUT="dat/dirmap.m.wyczalkowski-1000.gz"

DIRLIST="dat/m.wyczalkowski.1000.dirlist.tsv.gz"
FILELIST="dat/m.wyczalkowski.1000.filelist.tsv.gz"

OUT="dat/out-test.dat"


python3 src/make_dir_map_tree.py -e $DIRLIST -f $FILELIST -o $OUT
