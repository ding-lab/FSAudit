#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Generate FSAudit document for one volume

Usage:
  process_FS.sh [options] STEP

Options:
-h: Print this help message
-V VOLUME: This is the base path we are analyzing (/gscmnt/gc2737/ding).  Required
-T TIMESTAMP: Date in YYYYMMDD format (20190723), used for filenames.  Required
-N VOLNAME: Short name of system and volume, used for filenames (MGI.gc2737).  Required
-S SYSNAME: System name, used only for figure title (MGI).  Required

Arguments:
  STEP: one of: evaluate, process, summarize, plot, all, posteval

Analysis proceeds in four steps:
* `evaluate` recursively scans entire filesystem to collect information about all files.  Generates `rawstat` file
* `process` parses the `rawstat` file to generate `filestat` file
* `summarize` collapses `filestat` data by user and extension
* `plot` generates visual summary of file system usage

Step `all` evaluates all four steps. Step `posteval` evaluates all but `evaluate` step
EOF

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdV:T:N:S:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  # example of binary argument
      >&2 echo "Dry run" 
      CMD="echo"
      ;;
    V) 
      VOLUME=$OPTARG
      ;;
    T) 
      TIMESTAMP=$OPTARG
      ;;
    N) 
      VOLNAME=$OPTARG
      ;;
    S) 
      SYSNAME=$OPTARG
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi

STEP=$1

if [ $STEP != "evaluate" ] && [ $STEP != "process" ] && [ $STEP != "summarize" ] && [ $STEP != "plot" ] && [ $STEP != "all" ] && [ $STEP != "posteval" ]; then
    >&2 echo Unknown step : $STEP
    >&2 echo "$USAGE"
    exit 1
fi

if [ -z $VOLUME ]; then
    >&2 echo Volume name \(-V\) required
fi
if [ -z $TIMESTAMP ]; then
    >&2 echo Timestamp \(-T\) required
fi
if [ -z $VOLNAME ]; then
    >&2 echo Volume short name \(-N\) required
fi
if [ -z $SYSNAME ]; then
    >&2 echo System name \(-S\) required
fi

# These are typically not changed
DATD="dat"
LOGD="logs"

mkdir -p $LOGD
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
            >&2 echo Fatal error.  Exiting
            exit $rc;
        fi;
    done
}

function evaluate_volume {
    NOW=$(date)
    >&2 echo [ $NOW ] Running step evaluate
    OUT=$1

    LOGERR="$LOGD/${VOLNAME}.${TIMESTAMP}.err"
    LOGOUT="$LOGD/${VOLNAME}.${TIMESTAMP}.out"

    echo Analyzing $VOLUME
    echo Writing to $OUT
    echo Logs to $LOGERR and $LOGOUT
    CMD="bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR"
    run_cmd $CMD

    NERR=$(grep "Permission denied" $LOGERR | wc -l)
    if [[ "$NERR" != "0" ]]; then
        echo NOTE: $NERR counts of \"Permission denied\" in error log
    fi
}

function process_stats {
    DAT=$1
    OUT=$2
    NOW=$(date)
    >&2 echo [ $NOW ] Running step process

    CMD="python src/parse_fs.py -i $DAT  -o $OUT"
    run_cmd $CMD

    >&2 echo Written to $OUT
}

function summarize_stats {
    DAT=$1
    OUT=$2
    NOW=$(date)
    >&2 echo [ $NOW ] Running step summarize 
    # May need to do `conda activate R
    CMD="Rscript src/summarize_fs.R -Z $DAT $OUT"
    run_cmd $CMD
}

function plot_stats {
    DAT=$1
    
    NOW=$(date)
    >&2 echo [ $NOW ] Running step plot

    TITLE="${SYSNAME}:${VOLUME}"

    # -V vol_name: name of volume being processed, used for title
    # -D date: string representing date, used for title

    CMD="Rscript src/plot_FSAudit.R -L $TITLE -D $TIMESTAMP $DAT $FS_PLOT $FC_PLOT"
    run_cmd $CMD

    RLFS=$(readlink -f $FS_PLOT)
    RLFC=$(readlink -f $FC_PLOT)

    >&2 echo Final results written to:
    >&2 echo $RLFS
    >&2 echo $RLFC
}

RAW="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
PRO="$DATD/${VOLNAME}.${TIMESTAMP}.filestat.gz"  
SUM="$DATD/${VOLNAME}.${TIMESTAMP}.summary.dat"  
FS_PLOT="$DATD/${VOLNAME}.${TIMESTAMP}.FileSize.pdf"
FC_PLOT="$DATD/${VOLNAME}.${TIMESTAMP}.FileCount.pdf"

if [ $STEP == "evaluate" ] || [ $STEP == "all" ]; then
    evaluate_volume $RAW
fi

if [ $STEP == "process" ] || [ $STEP == "all" ] || [ $STEP == "posteval" ]; then
    process_stats $RAW $PRO
fi

if [ $STEP == "summarize" ] || [ $STEP == "all" ] || [ $STEP == "posteval" ]; then
    summarize_stats $PRO $SUM
fi

if [ $STEP == "plot" ] || [ $STEP == "all" ] || [ $STEP == "posteval" ]; then
    plot_stats $SUM $FS_PLOT $FC_PLOT
fi

NOW=$(date)
>&2 echo [ $NOW ] Completed successfully
