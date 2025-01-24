APP="src/dash-app.py"

# Paprika
INPUT="/Users/m.wyczalkowski/Projects/FSAudit/FSAudit.v2/FSAudit/dat/summary-20250121.dat"
MODE="localhost"
#MODE="main"

# Katmai
#INPUT="/home/mwyczalk_test/Projects/Dash/dat/summary-20210825.dat"


CMD="python $APP -m $MODE -i $INPUT $@"
echo $CMD
eval $CMD


#python src/dash-bubble_plot.py -i $INPUT $@

