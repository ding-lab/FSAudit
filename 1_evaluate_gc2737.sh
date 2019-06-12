# Analysis of /gscmnt/gc2737

VOLUME="/gscmnt/gc2737/ding"
#OUT="/gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.gz"
OUT="dat/test.rawstat.gz"
LOGERR="logs/gc2737.err"
LOGOUT="logs/gc2737.out"

mkdir -p logs

#echo See logs $LOGERR and $LOGOUT
#bash 1_evaluate_fs.sh $VOLUME $OUT > $LOGOUT 2> $LOGERR
bash src/evaluate_fs.sh $@ $VOLUME 

