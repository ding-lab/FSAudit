# Analysis of a volume

source FSAudit.config

mkdir -p $LOGD
mkdir -p $DATD

VOLUME="/diskmnt/Projects/Users"
OUT="$DATD/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
LOGERR="$LOGD/${VOLNAME}.${TIMESTAMP}.err"
LOGOUT="$LOGD/${VOLNAME}.${TIMESTAMP}.out"


echo See $LOGERR and $LOGOUT
bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR

