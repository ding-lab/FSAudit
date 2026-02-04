source config.sh
# read rawstat file and write out a filelist file

# Based on src/make_dir_map_tree.py

# Optional input data
# past_md5 - this provides past md5 calculations
#       This can be a previous filelist and/or output from `md5sum` calculations
# primary_list
#       list of directory or file paths which indicate which files are marked as primary
# exclude_list
#       list of directory or file paths which indicate which files are marked as excluded.  Not yet implemented


PRIMARY="config-dat/primary_list_storage1.tsv"

RAWSTAT="$OUTD/$RUN_NAME.rawstat.gz"  # this is typical
#>&2 echo DEV rawstat
#RAWSTAT="dev-dat/rawstat-10K.gz"

#OUT="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/FSAudit-Filelist-dev-20251203/filelist.dat.gz"

# the A indicates that this is the first filelist.  A new one will be created when new md5 sums are calculated
OUT="$OUTD/$RUN_NAME.filelistA.tsv.gz"

# -s: rdcw_swap.  Converts leading /rdcw to /storage1 to account for ris weirdness.  Typically necessary on compute1
ARGS="-s"

#>&2 echo DEV filelist
#PAST_MD5="dev-dat/filelistB.10000.tsv.gz"

PAST_MD5="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/FSAudit-Filelist-dev-20251203/FSAudit-Filelist-dev-20251203.filelistB.tsv.gz"

CMD="python3 src/make_filelist.py $ARGS -M $PAST_MD5 -p $PRIMARY $RAWSTAT | gzip > $OUT"

date
echo $CMD
eval $CMD

date
>&2 echo Written to $OUT

