#DIRLIST="dat/m.wyczalkowski.1000.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.1000.filelist.tsv.gz"
#OUT="dat/m.wyczalkowski.1000.dirmap2.tsv.gz"
#OUT="dat/m.wyczalkowski.1000.dirmap2.tsv"

#DIRLIST="dat/m.wyczalkowski.20250121.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.20250121.filelist.tsv.gz"
#OUT="dat/m.wyczalkowski.20250121.dirmap3.tsv"

P="dinglab.20250121"
DIRLIST="dat/$P/dirlist.tsv.gz"
FILELIST="dat/$P/$P.filelist.tsv.gz"
OUT="dat/$P/$P.dirmap3.tsv.gz"

#ERR="logs/make_dirmap2.err"
#>&2 echo Writing logs to $ERR

CMD="time python3 src/make_dir_map_tree.py -e $DIRLIST -f $FILELIST -o $OUT "
echo $CMD
eval $CMD

