source config.sh


FILELIST="$OUTD/${RUN_NAME}.filelist.tsv.gz"


#OUTD="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dev/FSAudit-md5"
OUT="$OUTD/${RUN_NAME}.md5-worklist.tsv"

zcat $FL | awk 'BEGIN{FS="\t";OFS="\t"}{if ($6 ~ /large/ && $5 == "." ) print}' > $OUT

>&2 echo Written to $OUT
