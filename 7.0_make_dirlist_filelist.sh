DAT="dat/m.wyczalkowski.20250121.rawstat-mod.gz"
#DIRLIST="dat/m.wyczalkowski.20250121.dirlist.tsv.gz"
#FILELIST="dat/m.wyczalkowski.20250121.filelist.tsv.gz"
DIRLIST="dat/m.wyczalkowski.1000.dirlist.tsv.gz"
FILELIST="dat/m.wyczalkowski.1000.filelist.tsv.gz"

HEAD=" head -n 1000 "

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     2	file_type	directory
#     3	file_size	4096
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:36.000000000 -0600
#     6	hard_links	3



>&2 echo READING $DAT



#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:36.000000000 -0600
gzcat $DAT | $HEAD | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory") print $1,$4,$5}' | gzip > $DIRLIST
>&2 echo Written to $DIRLIST


#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#     3	file_size	2
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:47.000000000 -0600
gzcat $DAT | $HEAD | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file") print $1,$3,$4,$5}' | gzip > $FILELIST
>&2 echo Written to $FILELIST
