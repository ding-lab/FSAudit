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

    # this fails when both file.dat and file.dat.gz exist, as it may return both.  the solution here
    # is to take the first one, and if it is the wrong one, calclulate the md5.  This should be fixed
    # to do a stricter match.  test-md5-list.tsv.gz can be used for testing
    FOUND=$(grep -w "$DATA_PATH" $PAST_MD5 | head -n1)

#/rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/817bab80-c418-4b48-9762-81ee012493af/TCGA-YU-A912-10A-01D-A438-10_Illumina_gdc_realn.bam
#15978506071
#estorrs
#2025-04-02 14:41:14.526825224 -0500
#2021-10-30 02:56:48.455189843 -0500
#2415ebd4d0d18a9a4eee165a69901023

    if [ -z "$FOUND" ]; then
        >&2 echo Novel MD5 for: $DATA_PATH 
        return 
    fi

    FS=$(echo "$FOUND" | cut -f 2)
    if [ "$FS" == "$FILE_SIZE" ]; then
        MD5=$(echo "$FOUND" | cut -f 6)
        >&2 echo Cached MD5 $MD5 for: $DATA_PATH 
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

FSLIM=1000000000    # 1,000,000,000

rm -f $OUT
touch $OUT

>&2 echo Reading $FILELIST
>&2 echo Old MD5 $PAST_MD5
>&2 echo Writing to $OUT

# filelist
# 1. /rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/817bab80-c418-4b48-9762-81ee012493af/TCGA-YU-A912-10A-01D-A438-10_Illumina_gdc_realn.bam
# 2. 15978506071
# 3. estorrs
# 4. 2025-05-05 17:13:33.208373172 -0500
# 5. 2021-10-30 02:56:48.455189843 -0500

START=`date`
>&2 echo Start: [$START] 

while read L; do
    FN=$(echo "$L" | cut -f 1)  # filename
    FS=$(echo "$L" | cut -f 2)  # filesize

    if (( $FS < $FSLIM )); then # skip to the next file if size is less than FSLIM 
#        >&2 echo Skipping $FN  / $FS
        continue
    fi

    CACHED_MD5=$(get_past_md5 $FN $FS)

    if [ -z "$CACHED_MD5" ]; then
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
        printf "%s\t%s\n" "$L" $CACHED_MD5 >> $OUT
    fi

done < <(zcat $FILELIST)

END=`date`
>&2 echo Start time: $START
>&2 echo End time: $END

>&2 echo Written to $OUT
