# Ad hoc script to evaluate md5s for files greater than 1Gb.  See discussion here:
#   /home/m.wyczalkowski/Projects/FSAudit/FSAudit-20250314/README.md

source config.sh

# use somehting like this to get the files > 1Gb
#  zcat dinglab.20250210.filelist.tsv.gz | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 > 1000000000) print }' | gzip > dinglab.20250210.filelist_gt_1Gb.tsv.gz

#FILELIST="dinglab.20250210.filelist_gt_1Gb.tsv.gz"
# FILELIST="filelist-test.tsv.gz"

# return md5 if it was previously calculated in the PAST_MD5 file
# check both the path and the file size for consistency
# return the string "none" if the file is not found
function get_past_md5 {
    DATA_PATH=$1
    FILE_SIZE=$2

    #FOUND=$(zcat $PAST_MD5_LIST | fgrep "$DATA_PATH")  # if compressed
    FOUND=$(cat $PAST_MD5_LIST | fgrep "$DATA_PATH")
# /rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/817bab80-c418-4b48-9762-81ee012493af/TCGA-YU-A912-10A-01D-A438-10_Illumina_gdc_realn.bam
# 15978506071
# estorrs
# 2021-10-30 02:56:48.455189843 -0500
# 2415ebd4d0d18a9a4eee165a69901023

    if [ -z "$FOUND" ]; then
        >&2 echo Not found past MD5 for: $DATA_PATH 
        return 
    fi

    FS=$(echo "$FOUND" | cut -f 2)
    if [ "$FS" == "$FILE_SIZE" ]; then
        MD5=$(echo "$FOUND" | cut -f 5)
        >&2 echo Found previously calculated MD5: $DATA_PATH 
        echo "$MD5"
        return
    fi

    >&2 echo Warning: File $DATA_PATH found but size mismatch \(expected $FS but found $FILE_SIZE\)
    return 
    
}

RUN_NAME="$VOL_NAME.$DATESTAMP"
OUTD="$OUTD_BASE/$RUN_NAME"


FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"
OUT="$OUTD/$RUN_NAME.filelist.gt_1Gb_md5.tsv"

FSLIM=1000000000

rm -f $OUT
touch $OUT

>&2 echo Reading $FILELIST
>&2 echo Old MD5 $PAST_MD5_LIST
>&2 echo Writing to $OUT

while read L; do
    FN=$(echo "$L" | cut -f 1)
    FS=$(echo "$L" | cut -f 2)

    if (( $FS < $FSLIM )); then
#        >&2 echo Skipping $FN  / $FS
        continue
    fi

    PAST_MD5=$(get_past_md5 $FN $FS)

    if [ -z $PAST_MD5 ]; then
        FSGB=$(echo "scale=2; $FS / 1024. / 1024 / 1024" | bc -l)
        if [ -e $FN ]; then
            NOW=$(date)
            >&2 echo [$NOW]: Calculating md5 for $FN \($FSGB Gb\)
            MD5=$(md5sum $FN | cut -f 1 -d ' ')
            printf "%s\t%s\n" "$L" $MD5 >> $OUT
        else
            >&2 echo NOTE: $FN does not exist.  Continuing
        fi
    else
        printf "%s\t%s\n" "$L" $PAST_MD5 >> $OUT
    fi

done < <(zcat $FILELIST)

>&2 echo Written to $OUT
