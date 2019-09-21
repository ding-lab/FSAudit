#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/
# Based on /gscuser/mwyczalk/projects/BICSEQ2/src/process_cases.sh

read -r -d '' USAGE <<'EOF'

Launch FSAudit workflow for multiple volumes.  

Usage:
  bash process_FS_parallel.sh -S DIRLIST [options] STEP

takes list of directory names and starts processing on each, calling `execute_workflow CASE`
Reads CaseList to get details (BAM, etc.) for each volumes.  Runs on host computer

Required options:
-S DIRLIST: details about directories to process

Optional options
-h: print usage information
-d: dry run: print commands but do not run
    This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
-1 : stop after one volume processed.
-J PARALLEL_CASES: Specify number of volumes to run in parallel.  If PARALLEL_CASES is 0 (default), run volumes sequentially

Arguments:
  STEP: one of: evaluate, process, summarize, plot, all, posteval
  see process_FS.sh for more details

Submission modes:
* parallel: launch a number of volume jobs simultaneously using `parallel`.  
* single: run all volume jobs sequentially.  

DIRLIST is a TSV file with the following columns for every volume to process:
 * VOLUME: This is the base path we are analyzing (/gscmnt/gc2737/ding)
 * TIMESTAMP: Date in YYYYMMDD format (20190723), used for filenames
 * VOLNAME: Short name of system and volume, used for filenames (MGI.gc2737)
 * SYSNAME: System name, used only for figure title (MGI)

EOF

# Background on `parallel` and details about blocking / semaphores here:
#    O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#    ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

while getopts ":hd1J:S:" opt; do
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
    S)
      DIRLIST=$OPTARG
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

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    echo "$USAGE"
    exit 1
fi
STEP=$1 # error checking will be handled by process_FS.sh

# DRYRUN implementation here takes into account that we're calling `parallel process_FS.sh`
# We want successive 'd' in DRYRUN to propagate to called functions as DRYARG_XXX
#   if DRYRUN is blank, execute normally
#   if DRYRUN is 'd', print out call to `parallel` instead of running it
#   if DRYRUN is 'dd' and longer, strip off `d` and pass remainder to `process_FS.sh`
DRYARG=""
DRYARG_WORKFLOW=""
if [ -z $DRYRUN ]; then   # DRYRUN not set
    :   # no-op
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    >&2 echo Dry run in $SCRIPT
elif [ $DRYRUN == "dd" ]; then  # `start_docker.sh -d`
    # DRYRUN has multiple d's: pop d off the argument and pass it to workflow
    DRYARG_WORKFLOW="-${DRYRUN%?}"
fi

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

    ARGS="$DRYARG_WORKFLOW -V $VOLUME -T $TIMESTAMP -N $VOLNAME -S $SYSNAME"

    # Reprocessing starting with step 2
    CMD="process_FS.sh $ARGS $STEP"

    echo "$CMD"
}

if [ -z $DIRLIST ]; then
    >&2 echo $SCRIPT: ERROR: DirList file not defined \(-S\)
    exit 1
fi
confirm $DIRLIST

# If PARALLEL_CASES is defined, set this as the
# number of jobs which can run at a time
if [ -z $PARALLEL_CASES ] ; then
    >&2 echo Running single volume at a time \(single mode\)
else
    >&2 echo Job submission with $PARALLEL_CASES volumes in parallel
    PARALLEL_MODE=1
fi

>&2 echo "Iterating over volumes in $DIRLIST "

if [ $PARALLEL_MODE ]; then
    LOGD="./logs"
    TMPD=$LOGD      # keep logs and tmp together.
    mkdir -p $LOGD
    test_exit_status
fi

# Loop over all remaining arguments
while read LINE; do

    VOLUME=$(echo "$LINE" | cut -f 1)
    TIMESTAMP=$(echo "$LINE" | cut -f 2)
    VOLNAME=$(echo "$LINE" | cut -f 3)
    SYSNAME=$(echo "$LINE" | cut -f 4)

    # VOLUME must be an existing directory
    if [ ! -d $VOLUME ]; then
        >&2 echo ERROR: Volume does not exist: $VOLUME
        exit 1
    fi

    CMD=$(get_launch_cmd $D)
    test_exit_status

    if [ $PARALLEL_MODE ]; then
        JOBLOG="$LOGD/FSAudit_parallel.${NAME}.log"
        CMD=$(echo "$CMD" | sed 's/"/\\"/g' )   # This will escape the quotes in $CMD 
        CMD="parallel --semaphore -j$PARALLEL_CASES --id $MYID --joblog $JOBLOG --tmpdir $TMPD \"$CMD\" "
    fi

    run_cmd "$CMD"

    if [ $JUSTONE ]; then
        break
    fi

done < $DIRLIST

# this will wait until all jobs completed
if [ $PARALLEL_MODE ] ; then
    CMD="parallel --semaphore --wait --id $MYID"
    run_cmd "$CMD"
fi


