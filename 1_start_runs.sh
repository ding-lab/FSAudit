source config.sh

bash src/launch_stat_fs.sh $VOL_NAME $VOL_PATH $DATESTAMP $OUTD_BASE

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Fatal error $rc: $!.  Exiting.
    exit $rc;
fi


