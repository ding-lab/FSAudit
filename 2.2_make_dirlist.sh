source config.sh

RAWSTAT="$OUTD/$RUN_NAME.rawstat.gz"  # this is typical

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"

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
>&2 echo Reading $RAWSTAT
>&2 echo Writing to $DIRLIST

# note that in some cases where filenames have weird characters (tab, newline), we run into problems downstream.  This can be filtered out by requiring that the
# path starts with "/"

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     4	owner_name	m.wyczalkowski
#     7	time_mod	2023-02-01 18:11:36.000000000 -0600
cat <(printf "file_name\ttowner_name\ttime_mod\n") <($ZCAT $RAWSTAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory" && $1 ~ /^\// ) print $1,$4,$7}') | gzip > $DIRLIST

>&2 date

