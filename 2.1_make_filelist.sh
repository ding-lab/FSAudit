source config.sh
# read rawstat file and write out a filelist file

# Based on src/make_dir_map_tree.py

# Optional input data
# past_md5 - this is a list of all past md5 calculations
#       based partly on make_md5_worklist.py
# primary_list
#       list of directory or file paths which indicate which files are marked as primary
# exclude_list
#       list of directory or file paths which indicate which files are marked as excluded


MD5="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20251102/dinglab.20251102.md5-raw-merged.txt"
PRIMARY="dev-dat/primary_list_storage1.tsv"

RAWSTAT="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20251124/dinglab.20251124.rawstat.gz"
#RAWSTAT="dev-dat/rawstat-malformed.tsv.gz"

#OUT="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/FSAudit-Filelist-dev-20251203/filelist.dat.gz"
OUT="$OUTD/$RUN_NAME.filelist.tsv.gz"

CMD="python3 src/make_filelist.py -m $MD5 -p $PRIMARY $RAWSTAT | gzip > $OUT"

date
echo $CMD
eval $CMD

date
>&2 echo Written to $OUT

