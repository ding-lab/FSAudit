# Launch md5 calculations on lab cluster
# uses xargs -P for parallelization

# on katmai suggest running this as root in tmux

source config.sh

#LIST="$OUTD/${RUN_NAME}.md5-worklist.tsv"
LIST="dev-dat/worklist.dat"
OUT="$OUTD/${RUN_NAME}.md5-raw.txt"
LOG="logs/${RUN_NAME}.md5-raw.log"

mkdir -p logs

N_PARALLEL=10

>&2 echo Reading $LIST
>&2 echo Writing $OUT
>&2 echo Logging $LOG

date

cat $LIST | cut -f 1 | xargs -I "{}" -n 1 -P $N_PARALLEL md5sum "{}" > $OUT 2> $LOG

date

# Note that this needs additional processing
# something like
# $ sed 's/  /\t/' katmai.20250916.md5-raw.tsv | gzip > katmai.20250916.md5.tsv.gz
# but also add header: "md5", "file_name"
