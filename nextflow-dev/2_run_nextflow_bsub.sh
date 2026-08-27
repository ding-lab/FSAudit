NF="main.nf"
#CONFIG="nextflow-demo.config"
CONFIG="nextflow-FSAudit.config"
OUTD="/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20260713-dev"
OUTD_W="$OUTD/work"
OUTD_R="$OUTD/results"
mkdir -p $OUTD_W
mkdir -p $OUTD_R

# this is good for testing on one particular machine, so the docker images don't load so long.  Not recommended for production
# LSF_ARGS="-m compute1-exec-135.ris.wustl.edu"

# defining queue both here and in the nextflow configuration file.  Want to avoid 24 hour limit on jobs in general-interactive
#LSF_ARGS="-q dinglab"

>&2 echo Work directory: $OUTD

NF_ARGS="-w $OUTD_W --outdir $OUTD_R"

# nextflow version 23.10.0.5889

# For development, thpc-terminal is better because it runs in foreground
# for production, thpc-batch is better because it doesn't have 24 hr time limit of interactive queue and don't need a tmux session.  Also, change
#   queue to a non-interactive one
# IMPORTANT - maintain the line continuation after LSF_DOCKER_VOLUMES ( \ )

LSF_DOCKER_VOLUMES="/scratch1/fs1/ris:/scratch1/fs1/ris /storage1/fs1/m.wyczalkowski/Active:/storage1/fs1/m.wyczalkowski/Active /storage1/fs1/dinglab/Active:/storage1/fs1/dinglab/Active" \
thpc-batch $LSF_ARGS bash -c "nextflow run $NF -c $CONFIG $NF_ARGS $@"

# simple one-liner
# LSF_DOCKER_VOLUMES="/scratch1/fs1/ris:/scratch1/fs1/ris" thpc-terminal bash -c "nextflow -v help"

# -m compute1-exec-135.ris.wustl.edu

#thpc-terminal bash -c "nextflow run $NF -c $CONFIG -w $OUTD_W -output-dir $OUTD_R $@"
#eval $CMD
#thpc-terminal bash -c "nextflow run $NF -c $CONFIG --outdir $OUTD $@"



