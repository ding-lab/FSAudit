#DIRLIST="dat/m.wyczalkowski.1000.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.1000.filelist.tsv.gz"

#DIRLIST="dat/m.wyczalkowski.20250121.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.20250121.filelist.tsv.gz"

DIRLIST="dat/dinglab.20250121.dirlist.tsv.gz"
FILELIST="dat/dinglab.20250121.filelist.tsv.gz"

OUT="dat/m.wyczalkowski.20250121.dirmap2.tsv"


CMD="time python3 src/make_dir_map_tree.py -e $DIRLIST -f $FILELIST -o $OUT"
echo $CMD
eval $CMD
