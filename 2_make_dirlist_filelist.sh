source config.sh


# DEV Start
#echo DEVELOPMENT DATA
#RUN_NAME="dev100"  # normally this is defined in config.sh
#DAT="/home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20251103/dev-data/dev100.rawstat.gz"
# DEV end

DAT="$OUTD/$RUN_NAME.rawstat.gz"
DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

ZCAT="zcat" # for mac, this should be gzcat

#$ examine_row dinglab.20250415.rawstat.dev-1000.tsv 15
#     1  file_name   /rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/44421b45-a0db-4525-8c4e-c6aff0398cad/80a6e8b4-9a1d-470c-8529-e21151a864bc_wxs_gdc_realn.bam.bai
#     2  file_type   regular file
#     3  file_size   4642216
#     4  owner_name  estorrs
#     5  time_birth  -
#     6  time_access 2025-04-02 14:32:21.316975250 -0500
#     7  time_mod    2022-01-13 08:20:48.384607000 -0600
#     8  hard_links  1

>&2 date
>&2 echo Reading $DAT
>&2 echo Writing to $DIRLIST

# note that in some cases where filenames have weird characters (tab, newline), we run into problems downstream.  This can be filtered out by requiring that the
# path starts with "/"

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     4	owner_name	m.wyczalkowski
#     7	time_mod	2023-02-01 18:11:36.000000000 -0600
#$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory" && $1 ~ /^\// ) print $1,$4,$7}' | gzip > $DIRLIST
#printf "file_name\ttowner_name\ttime_mod\n" > $OUT
cat <(printf "file_name\ttowner_name\ttime_mod\n") <($ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory" && $1 ~ /^\// ) print $1,$4,$7}') | gzip > $DIRLIST

>&2 date
>&2 echo Writing to $FILELIST

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#     3	file_size	2
#     4	owner_name	m.wyczalkowski
#     6 time_access 2025-04-02 14:32:21.316975250 -0500
#     7	time_mod	2023-02-01 18:11:47.000000000 -0600
#$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file" && $1 ~ /^\// ) print $1,$3,$4,$6,$7}' | gzip > $FILELIST

cat <(printf "file_name\tfile_size\towner_name\ttime_access\ttime_mod\n") <($ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file" && $1 ~ /^\// ) print $1,$3,$4,$6,$7}') | gzip > $FILELIST

>&2 date
