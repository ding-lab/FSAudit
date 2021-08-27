# -J N - specify number of jobs to run at once
#VOLUME_LIST="multi-run/VolumeList.dat"
VOLUME_LIST="multi-run/VolumeList.dat"
TIMESTAMP="20210825"
DATD="/gscmnt/gc2508/dinglab/mwyczalk/FSAudit/dat/20210825"

CMD="bash src/process_FS_parallel.sh -t $DATD -S process -T $TIMESTAMP -I $VOLUME_LIST $@ "
echo Running: $CMD
eval $CMD

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


