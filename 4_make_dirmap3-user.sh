
# dev
#P="head1M"
#P="dinglab.head20K"
P="dinglab.20250210"

DIRLIST="dat/$P/$P.dirlist.tsv.gz"
FILELIST="dat/$P/$P.filelist.tsv.gz"

# this also writes out dat/$P/dinglab.$P.dirmap3-USER.tsv.gz files
OUTD="dat/$P/dirmap"
mkdir -p $OUTD
OUT="$OUTD/$P.dirmap3.tsv.gz"
OUT_OWNER="dat/$P/$P.ownerlist.tsv"

CMD="time python3 src/make_dir_map_tree.py -u -U $OUT_OWNER -e $DIRLIST -f $FILELIST -o $OUT "
echo $CMD
eval $CMD

