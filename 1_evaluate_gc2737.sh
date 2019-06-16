# Analysis of /gscmnt/gc2737

VOLUME="/gscmnt/gc2737/ding"
OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.rawstat.gz"  
LOGERR="logs/gc2737.err"
LOGOUT="logs/gc2737.out"

mkdir -p logs

echo See logs $LOGERR and $LOGOUT
bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR

