# Ad hoc script to evaluate md5s for files greater than 1Gb.  See discussion here:
#   /home/m.wyczalkowski/Projects/FSAudit/FSAudit-20250314/README.md


# use somehting like this to get the files > 1Gb
#  zcat dinglab.20250210.filelist.tsv.gz | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 > 1000000000) print }' | gzip > dinglab.20250210.filelist_gt_1Gb.tsv.gz

#FILELIST="dinglab.20250210.filelist_gt_1Gb.tsv.gz"
# FILELIST="filelist-test.tsv.gz"
DATD="dat-scratch/m.wyczalkowski.20250331"
FILELIST="$DATD/m.wyczalkowski.20250331.filelist.tsv.gz"
OUT="$DATD/m.wyczalkowski.20250331.filelist.gt_1Gb_md5.tsv"

FSLIM=1000000000

rm -f $OUT
touch $OUT

>&2 echo Writing to $OUT

while read L; do
    FN=$(echo "$L" | cut -f 1)
    FS=$(echo "$L" | cut -f 2)

    if (( $FS < $FSLIM )); then
#        >&2 echo Skipping $FN  / $FS
        continue
    fi

    FSGB=$(echo "scale=2; $FS / 1024. / 1024 / 1024" | bc -l)
    if [ -e $FN ]; then
        NOW=$(date)
        >&2 echo [$NOW]: Processing $FN \($FSGB Gb\)
        MD5=$(md5sum $FN | cut -f 1 -d ' ')
        printf "%s\t%s\n" "$L" $MD5 >> $OUT
    else
        >&2 echo NOTE: $FN does not exist.  Continuing
    fi

done < <(zcat $FILELIST)

>&2 echo Written to $OUT
