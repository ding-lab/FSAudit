VOL_NAME="m.wyczalkowski"
DATESTAMP="20250331"
OUTD_BASE="/scratch1/fs1/dinglab/m.wyczalkowski/FSAudit/dat"

RUN_NAME="$VOL_NAME.$DATESTAMP"
OUTD="$OUTD_BASE/$RUN_NAME"

DAT="$OUTD/$RUN_NAME.rawstat.gz"

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

ZCAT="zcat" # for mac, this should be gzcat

# HEAD=" head -n 20000 "

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
#     5	time_mod	2023-02-01 18:11:36.000000000 -0600
$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory") print $1,$4,$5}' | gzip > $DIRLIST

>&2 date
>&2 echo Writing to $FILELIST

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#     3	file_size	2
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:47.000000000 -0600
$ZCAT $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file") print $1,$3,$4,$5}' | gzip > $FILELIST
>&2 date
