# Obtain the most recent value of mod_time from filestat files for each volume
# Also write out the corresponding filestat entry to separate file

# exclude any lines with "FSAudit" like this.  They are an artefact of old analysis
# MGI.gc2511  2019-09-20 18:54:36.163225266 +0000 /gscmnt/gc2511/dinglab/FSAudit/img/MGI.gc2511.20190918.FileCount.pdf    regular file    22401   mwyczalk    2019-09-20 18:54:36.163225266 +0000 1

DATD="/gscuser/mwyczalk/projects/FSAudit/all_MGI/dat/20200813"
# zcat MGI.gc2500.20200813.rawstat.gz | cut -f 5 | grep -v time_mod | sort | tail -n 1

# filestat.gz files - switching to these to evaluate only regular files
#   dirname, filename, ext, file_type, file_size, owner_name, time_mod, hard_links

TIMESTAMP="20200813"
VOLUME_LIST="/gscuser/mwyczalk/projects/FSAudit/all_MGI/config/VolumeList.dat"

# MGI.gc2500	/gscmnt/gc2500/dinglab
VNS=$(grep -v "^#" $VOLUME_LIST | cut -f 1 )

for VOLUME_NAME in $VNS; do

    FILESTAT="$DATD/$VOLUME_NAME.$TIMESTAMP.filestat.gz"
    if [ ! -e $FILESTAT ]; then
        >&2 echo ERROR: $FILESTAT does not exist
        exit 1
    fi

    # Exclude FSAudit lines
    CMD=" zcat $FILESTAT | grep -v FSAudit | cut -f 7 | grep -v time_mod | sort | tail -n 1"
#    >&2 echo Running: $CMD
    NEWEST_DATE=$( eval $CMD )

    # Now get this entry.  Print only top line
    #CMD=" zcat $FILESTAT  | grep \"$NEWEST_DATE\" "
    CMD=" zcat $FILESTAT  | grep \"$NEWEST_DATE\" | head -n 1"
    NEWEST_LINE=$( eval $CMD )

    printf "$VOLUME_NAME\t$NEWEST_DATE\t$NEWEST_LINE\n"
done 
