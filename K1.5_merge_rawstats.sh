source config.sh

# source all rawstat files together, excluding headers
# then, add header from one file
# file_name   file_type   file_size   owner_name  time_birth  time_access time_mod    hard_links

OUT="$OUTD/katmai.20251103b.rawstat.gz"

>&2 echo Reading $OUTD/dat/*.rawstat.gz
date
>&2 echo Writing $OUT

cat <( printf "file_name\tfile_type\tfile_size\towner_name\ttime_birth\ttime_access\ttime_mod\thard_links \n" ) <(zcat $OUTD/dat/*.rawstat.gz | fgrep -v file_name) | gzip > $OUT
date

>&2 echo Written to $OUT


