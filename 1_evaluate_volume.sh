# Analysis of a volume

TIMESTAMP="20190708"
VOLNAME="cptac3_scratch" # short name

VOLUME="/diskmnt/Projects/cptac_scratch"
OUT="/diskmnt/Projects/cptac_scratch/FSAudit/dat/${VOLNAME}.${TIMESTAMP}.rawstat.gz"  
LOGERR="logs/${VOLNAME}.${TIMESTAMP}.err"
LOGOUT="logs/${VOLNAME}.${TIMESTAMP}.out"

mkdir -p logs
mkdir -p dat

echo See logs $LOGERR and $LOGOUT
#bash src/evaluate_fs.sh $@ -o $OUT $VOLUME > $LOGOUT 2> $LOGERR
bash src/evaluate_fs.sh $@ -o $OUT $VOLUME 

