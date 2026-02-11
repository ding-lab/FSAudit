source ../config.sh
# Start with a real filelist and select N datafiles from it

N=100
DEV_RUN_NAME="DEV-100"

FILELIST="$OUTD/$RUN_NAME.filelistA.tsv.gz"

OUT="$OUTD/${DEV_RUN_NAME}.filelistA.tsv"
rm -f $OUT
printf "file_name\tfile_size\towner_name\ttime_access\ttime_mod\n" > $OUT

>&2 echo Reading: $FILELIST
>&2 echo Writing: $OUT

# sample only from first 1M lines
#zcat $FILELIST | head -n 1000000 | shuf -n $N >> $OUT
zcat $FILELIST | shuf -n $N >> $OUT

gzip -vf $OUT

