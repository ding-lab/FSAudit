
#FILELIST=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250909/dinglab.20250909.filelist.tsv.gz
#PAST_MD5=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728/dinglab.20250728.filelist.gt_1Gb_md5.tsv

# Switching to mwyczalkowski for manageability
#FILELIST="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/mwyczalkowski.20250815/mwyczalkowski.20250815.filelist.tsv.gz"
#PAST_MD5=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/m.wyczalkowski.20250612/m.wyczalkowski.20250612.filelist.gt_1Gb_md5.tsv

FILELIST=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dev/FSAudit-md5.dev-1000.filelist.tsv
PAST_MD5=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dev/FSAudit-md5.dev-1000.cached-filelist-md5.tsv

OUTD="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dev/FSAudit-md5"
OUT="$OUTD/md5-worklist.tsv"

python3 src/make_md5_worklist.py -m $PAST_MD5 -o $OUT $FILELIST

