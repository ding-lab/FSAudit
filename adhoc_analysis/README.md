# get most recently changed timestamp for each volume

This gives the most recent timestamp for each volume
    zcat MGI.gc2500.20200813.rawstat.gz | cut -f 5 | grep -v time_mod | sort | tail -n 1

Script `1_get_recent_volume_access.sh ` provides most recent value of time_mod for each volume.  It was run as,

bash 1_get_recent_volume_access.sh > time_mod.20200813.dat

