source ../config.sh
DEV_RUN_NAME="DEV-1K"

FILELIST="$OUTD/${DEV_RUN_NAME}.filelistA.tsv"
DIRLIST="$OUTD/${DEV_RUN_NAME}.dirlist.tsv"

>&2 echo Reading $FILELIST

TMP="$OUTD/tmp.tsv"
COUNT=0


while read L; do
  F=$(echo "$L" | cut -f 1)

  if [ "$F" == "file_name" ]; then
    continue
  fi

  ((COUNT++))
  >&2 echo $COUNT: Processing $F

  python3 ../src/fake_dirlist.py "$F" >> $TMP

done < <(zcat $FILELIST)

printf "file_name\ttowner_name\ttime_mod\n" > $DIRLIST
sort -u $TMP >> $DIRLIST
rm -f $TMP

echo Written to $DIRLIST
gzip -vf $DIRLIST
