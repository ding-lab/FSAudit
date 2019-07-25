# Analysis of a volume

source FSAudit.config

mkdir -p $LOGD
mkdir -p $DATD

OUT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
LOGERR="$LOGD/${VOLNAME}.${TIMESTAMP}.err"
LOGOUT="$LOGD/${VOLNAME}.${TIMESTAMP}.out"


echo Analyzing $VOLUME
echo Writing to $OUT
echo Logs to $LOGERR and $LOGOUT
bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR

NERR=$(grep "Permission denied" $LOGERR | wc -l)
if [[ "$NERR" != "0" ]]; then
    echo Note: $NERR counts of \"Permission denied\" in error log
fi
