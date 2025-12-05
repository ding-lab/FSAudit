RUN_NAME="DEV-1000"
OUTD="../dev-dat"
FLZ="$OUTD/filelist-1000.tsv.gz"

OUT="$OUTD/${RUN_NAME}.dirlist.tsv"
TMP="$OUTD/tmp.tsv"
rm -f $TMP


while read L; do
  F=$(echo "$L" | cut -f 1)

  if [ "$F" == "file_name" ]; then
    continue
  fi
  >&2 echo Processing $F

  python3 ../src/fake_dirlist.py "$F" >> $TMP

done < <(zcat $FLZ)

printf "file_name\ttowner_name\ttime_mod\n" > $OUT
sort -u $TMP >> $OUT

echo Written to $OUT
gzip -vf $OUT
