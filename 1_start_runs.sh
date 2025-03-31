# This should all be simplified.  Only evaluate step here
# Implement bsub stuff

# Volumes of interest
# dinglab	/storage1/fs1/dinglab/Active
# m.wyczalkowski	/storage1/fs1/m.wyczalkowski/Active

#bash src/launch_stat_fs.sh dinglab /storage1/fs1/dinglab/Active 20250331

bash src/launch_stat_fs.sh m.wyczalkowski /storage1/fs1/m.wyczalkowski/Active 20250331

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


