# Launch run for one volume

# Volumes of interest
# dinglab	/storage1/fs1/dinglab/Active
# m.wyczalkowski	/storage1/fs1/m.wyczalkowski/Active

#bash src/launch_stat_fs.sh dinglab /storage1/fs1/dinglab/Active 20250331

VOL_NAME="m.wyczalkowski"
VOL_PATH="/storage1/fs1/m.wyczalkowski/Active"
DATESTAMP="20250331"
OUTD_BASE="/scratch1/fs1/dinglab/m.wyczalkowski/FSAudit/dat"

bash src/launch_stat_fs.sh $VOL_NAME $VOL_PATH $DATESTAMP $OUTD_BASE

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


