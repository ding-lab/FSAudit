APP="src/dash-app.py"

# Shiso
INPUT="/Users/mwyczalk/Projects/FSAudit/FSAudit.v2/dat/20210825/summary-20210825.dat"
MODE="localhost"
#MODE="main"

# Katmai
#INPUT="/home/mwyczalk_test/Projects/Dash/dat/summary-20210825.dat"


CMD="python $APP -m $MODE -i $INPUT $@"
echo $CMD
eval $CMD


#python src/dash-bubble_plot.py -i $INPUT $@

