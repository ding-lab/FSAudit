# Start with a real filelist and select datafiles from it
# here, focusing on files > 1Gb for testing of md5 logic

N=100
RUN_NAME="BIG100"
FL="/home/mwyczalk_test/Projects/DataTracking/FSAudit/output/katmai.20251103/katmai.20251103b.filelist.tsv.gz"

OUT="dat/${RUN_NAME}.filelist.tsv"
rm -f $OUT
printf "file_name\tfile_size\towner_name\ttime_access\ttime_mod\n" > $OUT

zcat $FL | awk '{if ($2 > 1000000000) print}' | shuf -n 1000 >> $OUT



echo Written to $OUT
gzip -vf $OUT
