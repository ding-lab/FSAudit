# Analysis of /gscmnt/gc2737

TIMESTAMP="20190615"

VOLUME="/gscmnt/gc2737/ding"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.${TIMESTAMP}.rawstat.gz"  
LOGERR="logs/gc2737.${TIMESTAMP}.err"
LOGOUT="logs/gc2737.${TIMESTAMP}.out"

mkdir -p logs

echo See logs $LOGERR and $LOGOUT
bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR

