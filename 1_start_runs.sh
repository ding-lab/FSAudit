# -J N - specify number of jobs to run at once
VOLUME_LIST="config/VolumeList.dat"

bash src/process_FS_parallel.sh -I $VOLUME_LIST $@ 

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


