# filter dirmap and make dirtree HTML file for the entire volume

# retain only directories above a given size
# Write out data ready for input into dirtree

# Todo: combine filtering and HTML creatin into one step per user
# also, merge the all-volume and per-user code below

# Last, prepare a tar.gz of the HTML structure

# This assumes existence of dirtree in path

source config.sh

function filter_dirmap {
    DAT=$1
    OUT=$2
    LIM=$3

    >&2 echo Reading $DAT 
    >&2 echo Writing $OUT
    CAT="zcat"
    GZIP="gzip"
    COL="3"

    $CAT $DAT | awk -v LIM=$LIM 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > LIM) print}' | cut -f 3 |  $GZIP > $OUT
}

function make_dirtree {
    DAT=$1
    OUT=$2

    >&2 echo make_dirtree: Reading $DAT, Writing to $OUT
    zcat $DAT | dirtree -o $OUT
}


function process_all {
    # Process entire volume 
    START=`date`
    >&2 echo [$START] Processing entire volume
    LIM=100000000000 # 100G
    FILTER_LABEL="100G"

    mkdir -p "$OUTD/dirmap-filtered"

    >&2 echo filter_dirmap: $DAT $OUT $LIM
    DAT="$OUTD/dirmap/$RUN_NAME.dirmap3.tsv.gz"
    OUT_F="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
    filter_dirmap $DAT $OUT_F $LIM

    ## Make dirtree for the entire volume, showing all directories with >100Gb

    >&2 echo Processing all entries
    #DAT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$FILTER_LABEL.tsv.gz"
    HTML="$OUTD/html/$RUN_NAME.dirmap3-$FILTER_LABEL.html"
    mkdir -p $OUTD/html
    mkdir -p $OUTD/html/user

    make_dirtree $OUT_F $HTML

    >&2 echo Written to $OUT_F and $HTML

    END=`date`
    >&2 echo Start time: $START
    >&2 echo End time: $END
    >&2 echo Written to $OUT
}

####### below is from per-user

function process_user {
    >&2 echo Starting per user
    START=`date`
    # Process volume per-user
    LIM=10000000000 # 10G
    FILTER_LABEL="10G"

    ULIST="$OUTD/$RUN_NAME.ownerlist.tsv"

    >&2 echo ULIST $ULIST
    while read L; do

        U=$(echo "$L" | cut -f 1)
        if [ $U == "owner_name" ]; then
            continue
        fi

        NOW=`date`
        >&2 echo [$NOW] Processing user $U
        DAT="$OUTD/dirmap/$RUN_NAME.dirmap3-$U.tsv.gz"
        OUT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.tsv.gz"
        LIM=10000000000 # 10G
        filter_dirmap $DAT $OUT $LIM

    done < $ULIST

    ## Next make dirtree per user, showing all directories with >10Gb owned by that user
    >&2 echo Processing dirtree per user
    mkdir -p $OUTD/html/user

    make_dirtree $DAT $HTML

    while read L; do
        U=$(echo "$L" | cut -f 1)
        if [ $U == "owner_name" ]; then
            continue
        fi

        >&2 echo Processing user $U
        DAT="$OUTD/dirmap-filtered/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.tsv.gz"
        HTML="$OUTD/html/user/$RUN_NAME.dirmap3-$U-$FILTER_LABEL.html"
        make_dirtree $DAT $HTML
    done < $ULIST

    >&2 echo Written to $OUT and $HTML

    END=`date`
    >&2 echo Start time: $START
    >&2 echo End time: $END
    >&2 echo Written to $OUT
}

function make_tar {
    ### make tar file
    TAR="$OUTD/${RUN_NAME}.html.tar.gz"
    SRC="html"  # this is relative to $OUTD

    CMD="tar -C $OUTD -zcf $TAR $SRC"
    >&2 echo CMD=$CMD
    eval $CMD
    >&2 echo Written to $TAR
}

process_user
make_tar
