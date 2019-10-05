VOLUME_LIST="multi-run/VolumeList-short.dat"

# merge_FS.sh will
# 1. step summarize
#    - loop across all volumes and run `src/summarize_fs.R -g owner_name -V VOLUME_NAME >> merged_owner.dat`
#      to create dataset which has columns: owner_name  count   cumulative_size volume
# 2. step plot
#    - run `plot_FSAudit.R merged_owner.dat` to plot,
#      * (owner_name, volume) x count
#      * (owner_name, volume) x cumulative_size

# merge_FS.sh [-g owner_name | ext ] [-S step] [-I VOLUME_LIST] [volumes ...]

TIMESTAMP="-T 20191001"

bash src/merge_FS.sh -I $VOLUME_LIST $TIMESTAMP $@ 

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


