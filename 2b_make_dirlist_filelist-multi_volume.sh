source config.sh

JUSTONE=0

mkdir -p $OUTD

# CART_analysis	/diskmnt/Projects/CART_analysis
VOLUME_LIST="../dat/VolumeList-E.dat"  # E excludes home

DIRLIST="$OUTD/$RUN_NAME.dirlist.tsv.gz"
FILELIST="$OUTD/$RUN_NAME.filelist.tsv.gz"

if [ ! -e $VOLUME_LIST ]; then
    >&2 echo ERROR: $VOLUME_LIST does not exist
    exit 1
fi

if [ -e $DIRLIST ]; then
    >&2 echo Dirlist or filelist files exist.  Delete them first
    >&2 echo e.g. rm $DIRLIST $FILELIST
    exit 1
fi

rm -f $DIRLIST && touch $DIRLIST
rm -f $FILELIST && touch $DIRLIST

>&2 echo Looping over all volumes in $VOLUME_LIST
>&2 echo Writing to $DIRLIST and $FILELIST

while read L; do

    VOLUME_NAME=$(echo "$L" | cut -f 1)
#    VOLUME=$(echo "$L" | cut -f 2)

    >&2 echo `date`
    >&2 echo Processing volume $VOLUME_NAME

    DAT="$OUTD/dat/$VOLUME_NAME.rawstat.gz"

    # DAT must be an existing file
    if [ ! -e $DAT ]; then
        >&2 echo ERROR: File does not exist: $DAT
        exit 1
    fi

    # note that in some cases where filenames have weird characters (tab, newline), we run into problems downstream.  This can be filtered out by requiring that the
    # path starts with "/"

    #     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
    #     4	owner_name	m.wyczalkowski
    #     7	time_mod	2023-02-01 18:11:36.000000000 -0600
    #       volume      CART_analysis           #    this is new for katmai

    zcat $DAT | awk -v volume=$VOLUME_NAME 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "directory" && $1 ~ /^\// ) print $1,$4,$7,volume}' | gzip >> $DIRLIST


    #     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
    #     3	file_size	2
    #     4	owner_name	m.wyczalkowski
    #     6 time_access 2025-04-02 14:32:21.316975250 -0500
    #     7	time_mod	2023-02-01 18:11:47.000000000 -0600
    zcat $DAT | awk 'BEGIN{FS="\t";OFS="\t"}{if ($2 == "regular file" && $1 ~ /^\// ) print $1,$3,$4,$6,$7}' | gzip >> $FILELIST

    if [ $JUSTONE == 1 ]; then
        break
    fi
done <$VOLUME_LIST


>&2 date
