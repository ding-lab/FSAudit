#!/bin/bash

# TODO: MGI mode is not yet functional.  Need to think through job submission on MGI
# Right now it is following model of defering gsub submission to some other script, whereas
# we want to call bsub / gsub here.  Test gsub submission, think through how to use groups

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/
# Based on /gscuser/mwyczalk/projects/BICSEQ2/src/process_cases.sh

read -r -d '' USAGE <<'EOF'

Launch FSAudit workflow for multiple cases.  

Usage:
  bash FSAudit_parallel.sh -S DIRLIST [options] 

takes list of directory names and starts processing on each, calling `execute_workflow CASE`
Reads CaseList to get details (BAM, etc.) for each case.  Runs on host computer

Required options:
-S DIRLIST: path to list of directories to process

Optional options
-h: print usage information
-d: dry run: print commands but do not run
    This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
-1 : stop after one case processed.
-M: run in MGI environment
-J PARALLEL_CASES: Specify number of cases to run in parallel.  
   * If not MGI environment, run this many cases at a time using `parallel`.  If not defined, run cases sequentially
   * If in MGI environment, and LSF_GROUP defined, run this many cases at a time; otherwise, run all jobs simultaneously
-g LSF_GROUP: LSF group to use starting job (MGI specific)
      details: https://confluence.ris.wustl.edu/pages/viewpage.action?pageId=27592450
      See also https://github.com/ding-lab/importGDC.CPTAC3

Submission modes:
* MGI: launch all case jobs as bsub commands.  Does not block, number of jobs to run in parallel is controlled via job groups.  Defined if MGI mode (-M)
* parallel: launch a number of case jobs simultaneously using `parallel` on non-MGI system.  Blocks until all jobs finished. Mode is parallel if -J option defined
* single: run all case jobs sequentially on non-MGI system.  Blocks until all jobs finished.  Mode is single if -J option not defined

EOF

# Background on `parallel` and details about blocking / semaphores here:
#    O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
#    ;login: The USENIX Magazine, February 2011:42-47.
# [ https://www.usenix.org/system/files/login/articles/105438-Tange.pdf ]

SCRIPT=$(basename $0)
SCRIPT_PATH=$(dirname $0)

while getopts ":hd1MJ:g:S:" opt; do
  case $opt in
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d)  # -d is a stack of parameters, each script popping one off until get to -d
      DRYRUN="d$DRYRUN"
      ;;
    1) 
      >&2 echo "Will stop after one case" 
      JUSTONE=1
      ;;
    M)  
      MGI=1
      >&2 echo MGI Mode
      ;;
    J) 
      PARALLEL_CASES=$OPTARG
      NOW=$(date)
      MYID=$(date +%Y%m%d%H%M%S)
      ;;
    g) # define LSF_GROUP
      LSF_GROUP="$OPTARG"
      RUN_ARGS="$RUN_ARGS -g $LSF_GROUP"
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
    DDIR=$1
    # See /gscuser/mwyczalk/projects/BICSEQ2/src/process_cases.sh for implementation with data read from config file

    if [ ! -d $DDIR ]; then 
        >&2 echo ERROR: Directory $DDIR does not exist 
        exit 1
    fi

#    CMD="cd $DDIR && bash A_process_all.sh"

    # Reprocessing starting with step 2
    CMD="cd $DDIR && bash 2_process_stats.sh && bash 3_summarize_stats.sh && bash 4_plot_stats.sh"

    echo "$CMD"
}

if [ -z $DIRLIST ]; then
    >&2 echo $SCRIPT: ERROR: DirList file not defined \(-S\)
    exit 1
fi
confirm $DIRLIST

# set up LSF_GROUPS if appropriate
# If user defines LSF_GROUP in MGI environment, check to make sure this group exists,
# and exit with an error if it does not.  If PARALLEL_CASES is defined, set this as the
# number of jobs which can run at a time
if [ "$MGI" == 1 ] ; then
    >&2 echo Not implemented
    exit 1

    >&2 echo Job submission at MGI using bsub
    if [ $LSF_GROUP ] ; then
    # test if LSF Group is valid.  
        >&2 echo Evaluating LSF Group $LSF_GROUP
        LSF_OUT=$( bjgroup -s $LSF_GROUP )
        if [ -z "$LSF_OUT" ]; then
            >&2 echo ERROR: LSF Group $LSF_GROUP does not exist.
            >&2 echo Please create with,
            >&2 echo "   bgadd /mwyczalk/test_group"
            exit 1
        fi
        if [ $PARALLEL_CASES ]; then
            >&2 echo Setting job limit of $PARALLEL_CASES for LSF Group $LSF_GROUP
            bgmod -L $PARALLEL_CASES $LSF_GROUP
            LSF_OUT=$( bjgroup -s $LSF_GROUP )
        fi
        >&2 echo "$LSF_OUT"
        >&2 echo Job limit may be modified with, \`bgmod -L NUMBER_JOBS $LSF_GROUP \`
    fi
else
    if [ -z $PARALLEL_CASES ] ; then
        >&2 echo Running single case at a time \(single mode\)
    else
        >&2 echo Job submission with $PARALLEL_CASES cases in parallel
        PARALLEL_MODE=1
    fi
fi


>&2 echo "Iterating over cases in $DIRLIST "

# Loop over all remaining arguments
while read D ; do
    # Convenience name which is ad hoc.  want to use file with additional info in future
    NAME=$(echo $D | cut -f 3 -d "/")
    >&2 echo Processing DIR $D \($NAME\)

    CMD=$(get_launch_cmd $D)
    test_exit_status

    LOGD="./log"
    mkdir -p $LOGD
    test_exit_status
    TMPD="./tmp"
    mkdir -p $TMPD
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


