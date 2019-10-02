#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/
# Based on /gscuser/mwyczalk/projects/BICSEQ2/src/process_cases.sh


read -r -d '' USAGE <<'EOF'

Launch FSAudit workflow for multiple volumes.  

Usage:
  bash process_FS_parallel.sh -I VOLUME_LIST [options] [VOLUME_NAME1 ...]

Takes list of volume names if provided, or processes all entries in VOLUME_LIST,
calling for each volume in VOLUME_LIST:

    process_FS.sh -V $VOLUME -N $VOLUME_NAME1

Required options:
-I VOLUME_LIST: details about volumes or directories to process

Optional options
-h: print usage information
-d: dry run: print commands but do not run
    This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
-1 : stop after one volume processed.
-S STEP : one of evaluate, process, summarize, plot, all, posteval.  Default is all.  See process_FS.sh for more details
-T TIMESTAMP: Date in YYYYMMDD format (20190723), used for filenames.  Default is based on today's date
-J PARALLEL_CASES: Specify number of volumes to run in parallel.  If PARALLEL_CASES is 0 (default), run volumes sequentially
-t DATD: directory where analysis data (raw, filestat, summary, plots) is written.  Default : ./dir
-l LOGD: directory where runtime logs are written.  Default : ./logs

Arguments:

Submission modes:
* parallel: launch a number of volume jobs simultaneously using `parallel`.  
* single: run all volume jobs sequentially.  

VOLUME_LIST is a TSV file with the following columns for every volume to process:
 * VOLUME_NAME: Short name of system and volume, used for filenames (MGI.gc2737)
 * VOLUME: This is the base path we are analyzing (/gscmnt/gc2737/ding)

Files written to LOGD include STDERR, STDOUT, and logs per volume as generated by process_FS.sh.  Logs written only
if running in parallel mode

EOF

# Background on `parallel` and details about blocking / semaphores here:
#    O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#    ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

# Default values
DATD="dat"
LOGD="logs"
STEP="all"
TIMESTAMP=$(date +%Y%m%d)
XARGS=""    # These are passed directly to process_FS.sh

while getopts ":hd1J:I:t:l:S:T:" opt; do
  case $opt in
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d)  # -d is a stack of parameters, each script popping one off until get to -d
      DRYRUN="d$DRYRUN"
      ;;
    1) 
      >&2 echo "Will stop after one volume" 
      JUSTONE=1
      ;;
    J) 
      PARALLEL_CASES=$OPTARG
      NOW=$(date)
      MYID=$(date +%Y%m%d%H%M%S)
      ;;
    I)
      VOLUME_LIST=$OPTARG
      ;;
    t) 
      DATD=$OPTARG
      XARGS="$XARGS -t $OPTARG"
      ;;
    l) 
      LOGD=$OPTARG
      XARGS="$XARGS -l $OPTARG"
      ;;
    S) 
      STEP=$OPTARG
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

if [ $STEP != "evaluate" ] && [ $STEP != "process" ] && [ $STEP != "summarize" ] && [ $STEP != "plot" ] && [ $STEP != "all" ] && [ $STEP != "posteval" ]; then
    >&2 echo Unknown step : $STEP
    >&2 echo "$USAGE"
    exit 1
fi

# DRYRUN implementation here takes into account that we're calling `parallel process_FS.sh`
# We want successive 'd' in DRYRUN to propagate to called functions as DRYARG_XXX
#   if DRYRUN is blank, execute normally
#   if DRYRUN is 'd', print out call to `parallel` instead of running it
#   if DRYRUN is 'dd' and longer, strip off `d` and pass remainder to `process_FS.sh`
DRYARG_WORKFLOW=""
if [ -z $DRYRUN ]; then   # DRYRUN not set
    :   # no-op
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    >&2 echo Dry run in $SCRIPT
elif [ $DRYRUN == "dd" ]; then  # `start_docker.sh -d`
    # DRYRUN has multiple d's: pop d off the argument and pass it to workflow
    DRYARG_WORKFLOW="-${DRYRUN%?}"
fi

mkdir -p $LOGD
mkdir -p $DATD

# Evaluate given command CMD either as dry run or for real
function run_cmd {
    CMD=$1

    if [ "$DRYRUN" == "d" ]; then
        >&2 echo Dryrun: $CMD
    else
        >&2 echo Running: $CMD
        eval $CMD
        test_exit_status
    fi
}

function confirm {
    FN=$1
    if [ ! -s $FN ]; then
        >&2 echo ERROR: $FN does not exist or is empty
        exit 1
    fi
}

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}

function get_launch_cmd {
    VOLUME=$1
    VOLUME_NAME=$2
    TIMESTAMP=$3

    ARGS="$XARGS $DRYARG_WORKFLOW -V $VOLUME -T $TIMESTAMP -N $VOLUME_NAME"

    CMD="bash src/process_FS.sh $ARGS $STEP"

    echo "$CMD"
}

if [ -z $VOLUME_LIST ]; then
    >&2 echo $SCRIPT: ERROR: VOLUME_LIST file not defined \(-S\)
    exit 1
fi
confirm $VOLUME_LIST

# this allows us to get volume names in one of three ways:
# 1: process_FS_parallel.sh VN1 VN2 ...
# 2: cat volume_names.txt | cq -
# 3: process all volume names in VOLUME_LIST file
# Note that if no cases defined, assume CASE='-'
if [ "$#" == 0 ]; then
    VNS=$(grep -v "^#" $VOLUME_LIST | cut -f 1 )
elif [ "$1" == "-" ] ; then
    VNS=$(cat - )
else
    VNS="$@"
fi


# If PARALLEL_CASES is defined, set this as the
# number of jobs which can run at a time
if [ -z $PARALLEL_CASES ] ; then
    >&2 echo Running single volume at a time \(single mode\)
else
    >&2 echo Job submission with $PARALLEL_CASES volumes in parallel
    PARALLEL_MODE=1
fi

if [ $PARALLEL_MODE ]; then
    LOGD="./logs"
    TMPD=$LOGD      # keep logs and tmp together.
    mkdir -p $LOGD
    test_exit_status
fi

# Loop over all volume names, get volume path from VOLUME_LIST
for VOLUME_NAME in $VNS; do

    if ! grep -F -q $VOLUME_NAME $VOLUME_LIST ; then
        >&2 echo ERROR: $VOLUME_NAME not found in $VOLUME_LIST
        exit 1
    fi

    VOLUME=$(grep $VOLUME_NAME $VOLUME_LIST | cut -f 2)

    # VOLUME must be an existing directory
    if [ ! -d $VOLUME ]; then
        >&2 echo ERROR: Volume does not exist: $VOLUME
        exit 1
    fi

    CMD=$(get_launch_cmd $VOLUME $VOLUME_NAME $TIMESTAMP )
    test_exit_status

    if [ $PARALLEL_MODE ]; then
        LOGERR="$LOGD/${VOLUME_NAME}.${TIMESTAMP}.process_FS.err"
        LOGOUT="$LOGD/${VOLUME_NAME}.${TIMESTAMP}.process_FS.out"
        CMD="$CMD > $LOGOUT 2> $LOGERR"

        JOBLOG="$LOGD/${VOLUME_NAME}.${TIMESTAMP}.process_FS.log"
        CMD=$(echo "$CMD" | sed 's/"/\\"/g' )   # This will escape the quotes in $CMD 
        CMD="parallel --semaphore -j$PARALLEL_CASES --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
    fi

    run_cmd "$CMD"

    if [ $JUSTONE ]; then
        break
    fi

done 

# this will wait until all jobs completed
if [ $PARALLEL_MODE ] ; then
    CMD="parallel --semaphore --wait --id $MYID"
    run_cmd "$CMD"
fi


