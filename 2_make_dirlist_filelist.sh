source config.sh

#VOL_NAME="m.wyczalkowski"
#DATESTAMP="20250331"
#OUTD_BASE="/scratch1/fs1/dinglab/m.wyczalkowski/FSAudit/dat"

RUN_NAME="$VOL_NAME.$DATESTAMP"
OUTD="$OUTD_BASE/$RUN_NAME"

DAT="$OUTD/$RUN_NAME.rawstat.gz"

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

ZCAT="zcat" # for mac, this should be gzcat

# HEAD=" head -n 20000 "

# circa 20250415
#$ examine_row dinglab.20250415.rawstat.dev-1000.tsv 15
#     1  file_name   /rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/44421b45-a0db-4525-8c4e-c6aff0398cad/80a6e8b4-9a1d-470c-8529-e21151a864bc_wxs_gdc_realn.bam.bai
#     2  file_type   regular file
#     3  file_size   4642216
#     4  owner_name  estorrs
#     5  time_birth  -
#     6  time_access 2025-04-02 14:32:21.316975250 -0500
#     7  time_mod    2022-01-13 08:20:48.384607000 -0600
#     8  hard_links  1

# older
#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     2	file_type	directory
#     3	file_size	4096
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:36.000000000 -0600
#     6	hard_links	3

>&2 date
>&2 echo Reading $DAT
>&2 echo Writing to $DIRLIST

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     4	owner_name	m.wyczalkowski
#     7	time_mod	2023-02-01 18:11:36.000000000 -0600
$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory") print $1,$4,$7}' | gzip > $DIRLIST

>&2 date
>&2 echo Writing to $FILELIST

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#     3	file_size	2
#     4	owner_name	m.wyczalkowski
#     6 time_access 2025-04-02 14:32:21.316975250 -0500
#     7	time_mod	2023-02-01 18:11:47.000000000 -0600
$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file") print $1,$3,$4,$6,$7}' | gzip > $FILELIST
>&2 date
