#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Generate FSAudit document across multiple volumes

Usage:
  merge_FS.sh [options] [VOLUME_NAME1 ...]

Iterates over list of volumes to create combined dataset grouped by extension or owner,
and plots file counts and cumulative sizes across various volumes

Options:
-h: Print this help message
-d: dry run: print commands but do not run
-g group.by: variable by which to group file data, one of "owner_name" (default) or "ext"
-t DATD: directory where analysis data is written.  Default : ./dir
# ** confirm if necessary ** -l LOGD: directory where runtime logs are written.  Default : ./logs
-S STEP : one of summarize, plot, all.  Default: all
-I VOLUME_LIST: list of volumes or directories to process.  Only the first column (VOLUME_NAME) is used
-T TIMESTAMP: Date in YYYYMMDD format (20190723), used for filenames.  Default is based on today's date

For step `summarize` a list of VOLUME_NAMEs is required.  VOLUME_NAME is short
name of system and volume, e.g., MGI.gc2737.  If list of one or more
VOLUME_NAME is provided then that list is processed.  If VOLUME_NAME1 is '-',
read list of VOLUME_NAMEs from stdin.  If VOLUME_NAME is not provided, -I
VOLUME_LIST is required and all volumes in that file are processed.

Analysis proceeds in two steps:
`summarize` collapses `filestat` data by user or extension, generates 'summary' file
     to create dataset which has columns: owner_name  count   cumulative_size volume
`plot` generates visual summary of file system usage, writes FileCount and FileSize PDF files
     * (owner_name, volume) x count
     * (owner_name, volume) x cumulative_size
Step `all` evaluates both steps

EOF

# core summary:
#   - loop across all volumes and run `src/summarize_fs.R -g owner_name -V VOLUME_NAME >> merged_owner.dat`
# core plot:
#   - run `plot_FSAudit.R merged_owner.dat` to plot,

# Default values
DATD="dat"
#LOGD="logs"
TIMESTAMP=$(date +%Y%m%d)
STEP="all"
GROUP_BY="owner_name"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdg:t:S:I:T:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  # example of binary argument
      DRYRUN="d"
      ;;
    g) 
      GROUP_BY=$OPTARG
      ;;
    t) 
      DATD=$OPTARG
      ;;
    S) 
      STEP=$OPTARG
      ;;
    I) 
      VOLUME_LIST=$OPTARG
      ;;
    T) 
      TIMESTAMP=$OPTARG
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ $STEP != "summarize" ] && [ $STEP != "plot" ] && [ $STEP != "all" ] ; then
    >&2 echo Unknown step : $STEP
    >&2 echo "$USAGE"
    exit 1
fi

if [ $GROUP_BY != "owner_name" ] && [ $GROUP_BY != "ext" ] ; then
    >&2 echo Unknown group.by : $GROUP_BY
    >&2 echo "$USAGE"
    exit 1
fi

#mkdir -p $LOGD
mkdir -p $DATD

function run_cmd {
    CMD=$1

    NOW=$(date)
    if [ "$DRYRUN" == "d" ]; then
        >&2 echo [ $NOW ] Dryrun: $CMD
    else
        >&2 echo [ $NOW ] Running: $CMD
        eval $CMD
        test_exit_status
        NOW=$(date)
        >&2 echo [ $NOW ] Completed successfully
    fi
}

function confirm {
    FN=$1
    WARN=$2
    NOW=$(date)
    if [ ! -s $FN ]; then
        if [ -z $WARN ]; then
            >&2 echo [ $NOW ] ERROR: $FN does not exist or is empty
            exit 1
        else
            >&2 echo [ $NOW ] WARNING: $FN does not exist or is empty.  Continuing
        fi
    fi
}

# Called after running scripts to catch fatal (exit 1) errors
# works with piped calls ( S1 | S2 | S3 > OUT )
function test_exit_status {
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal ERROR.  Exiting
            exit $rc;
        fi;
    done
}

function summarize_grouped_stats {
    DAT=$1
    VOLUME_NAME=$2
    OUT=$3
    FIRSTTIME=$4    # treat the first time through differently

    # Treat subsequent times through differently: append to file and don't write header
    ARG=""
    if [ $FIRSTTIME == 0 ]; then
       ARG="-a -H" 
    fi
    CMD="Rscript src/summarize_fs.R $ARG -g $GROUP_BY -V $VOLUME_NAME -Z $DAT $OUT"
    run_cmd "$CMD"
}

function plot_stats {
    DAT=$1
    
    NOW=$(date)
    >&2 echo [ $NOW ] Running step plot
    
    if [ $GROUP_BY != "owner_name" ] ; then
        TITLE="Grouping by Owner"
    elif [ $GROUP_BY != "ext" ] ; then
        TITLE="Grouping by Volume"
    else
        >&2 echo ERROR: Uknown GROUP_BY value $GROUP_BY
        exit
    fi

    # -V vol_name: name of volume being processed, used for title
    # -D date: string representing date, used for title
    CMD="Rscript src/plot_FSAudit.R -L $TITLE -D $TIMESTAMP $DAT $FS_PLOT $FC_PLOT"
    run_cmd "$CMD"

    RLFS=$(readlink -f $FS_PLOT)
    RLFC=$(readlink -f $FC_PLOT)

    >&2 echo Final results written to:
    >&2 echo $RLFS
    >&2 echo $RLFC
}

# These are be separated by whether grouping is by extension or owner
SUM="$DATD/${GROUP_BY}.${TIMESTAMP}.summary.dat"  
FS_PLOT="$DATD/${GROUP_BY}.${TIMESTAMP}.FileSize.pdf"
FC_PLOT="$DATD/${GROUP_BY}.${TIMESTAMP}.FileCount.pdf"

if [ $STEP == "summarize" ] || [ $STEP == "all" ] ; then
    NOW=$(date)
    >&2 echo [ $NOW ] Running step summarize 
    # for step Summarize we can get list of volume names in one of 3 ways:
    # 1: merge_FS.sh VN1 VN2 ...
    # 2: cat volume_names.txt | merge_FS.sh -
    # 3: process all volume names in VOLUME_LIST file
    #    This requires that VOLUME_LIST is defined
    if [ "$#" == 0 ]; then
        if [ -z $VOLUME_LIST ]; then 
            >&2 echo ERROR: -I VOLUME_LIST must be defined if no VOLUME_NAME provided
            exit 1
        fi
        confirm $VOLUME_LIST
        VNS=$(grep -v "^#" $VOLUME_LIST | cut -f 1 )
    elif [ "$1" == "-" ] ; then
        VNS=$(cat - )
    else
        VNS="$@"
    fi

    FIRSTTIME=1
    # Loop over all volume names
    for VOLUME_NAME in $VNS; do
        PRO="$DATD/${VOLUME_NAME}.${TIMESTAMP}.filestat.gz"  
        confirm $PRO
        summarize_grouped_stats $PRO $VOLUME_NAME $SUM $FIRSTTIME
        FIRSTTIME=0
    done 
fi

if [ $STEP == "plot" ] || [ $STEP == "all" ] ; then
    plot_stats $SUM $FS_PLOT $FC_PLOT
fi

NOW=$(date)
>&2 echo [ $NOW ] Completed successfully
