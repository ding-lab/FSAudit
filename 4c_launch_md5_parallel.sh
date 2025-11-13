# Launch md5 calculations on lab cluster
# uses xargs -P for parallelization

# Suggest running this as root in tmux

source config.sh

ALT_RUN_NAME="katmai.20251103b"
RUN_NAME=$ALT_RUN_NAME

LIST="$OUTD/${RUN_NAME}.md5-worklist.tsv"
OUT="$OUTD/${RUN_NAME}.md5-raw.txt"
LOG="logs/${RUN_NAME}.md5-raw.log"

N_PARALLEL=10

>&2 echo Reading $LIST
>&2 echo Writing $OUT
>&2 echo Logging $LOG

date

cat $LIST | tail -n +2 | cut -f 1 | xargs -I "{}" -n 1 -P $N_PARALLEL md5sum "{}" > $OUT 2> $LOG

date

# Note that this needs additional processing
# something like
# $ sed 's/  /\t/' katmai.20250916.md5-raw.tsv | gzip > katmai.20250916.md5.tsv.gz
# but also add header: "md5", "file_name"
