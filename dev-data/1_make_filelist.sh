# Start with a real filelist and select N datafiles from it

N=100
RUN_NAME="DEV-100"
FL="/home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20251103/katmai.20251103.filelist.tsv.gz"

OUT="dat/${RUN_NAME}.filelist.tsv"
rm -f $OUT
printf "file_name\tfile_size\towner_name\ttime_access\ttime_mod\n" > $OUT

# sample only from first 1M lines
#zcat $FL | head -n 1000000 | shuf -n $N >> $OUT
zcat $FL | shuf -n $N >> $OUT



echo Written to $OUT
gzip -vf $OUT
