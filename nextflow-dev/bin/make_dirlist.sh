RAWSTAT=$1

>&2 echo Reading $RAWSTAT
>&2 echo Writing dirlist.tsv.gz

cat <(printf 'file_name\ttowner_name\ttime_mod\n') <(zcat $RAWSTAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory" && $1 ~ /^\// ) print $1,$4,$7}') | gzip > dirlist.tsv.gz
