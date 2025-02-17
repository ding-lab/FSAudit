# This should all be simplified.  Only evaluate step here
# Implement bsub stuff

# -J N - specify number of jobs to run at once
#VOLUME_LIST="multi-run/VolumeList.dat"
VOLUME_LIST="multi-run/VolumeList-storage1.dat"
# evaluate, process, summarize, plot, all, posteval
bash src/process_FS_parallel.sh -s evaluate -I $VOLUME_LIST $@ 

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


