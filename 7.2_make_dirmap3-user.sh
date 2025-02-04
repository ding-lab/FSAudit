
# dev
#P="head1M"
#P="dinglab.head20K"
P="dinglab.20250121"

DIRLIST="dat/$P/$P.dirlist.tsv.gz"
FILELIST="dat/$P/$P.filelist.tsv.gz"

mkdir -p dat/$P
# this also writes out dat/$P/dinglab.$P.dirmap3-USER.tsv.gz files
OUT="dat/$P/$P.dirmap3.tsv.gz"
OUT_OWNER="dat/$P/$P.ownerlist.tsv"

#DIRLIST="dat/m.wyczalkowski.20250121.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.20250121.filelist.tsv.gz"
#OUT="dat/m.wyczalkowski.20250121.dirmap3.tsv"

#DIRLIST="dat/dinglab.20250121.dirlist.tsv.gz"
#FILELIST="dat/dinglab.20250121.filelist.tsv.gz"
#OUT="dat/dinglab.20250121.dirmap3-$OWNER.tsv.gz"
#OUT_OWNER="dat/dinglab.20250121.ownerlist.tsv"

#ERR="logs/make_dirmap2.err"
#>&2 echo Writing logs to $ERR

CMD="time python3 src/make_dir_map_tree.py -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "
echo $CMD
eval $CMD

