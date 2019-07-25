# Run steps 1-4, check for failure after each.
# Modeled after https://github.com/ding-lab/discover.CPTAC3.b1/blob/master/1_process_all.sh
source FSAudit.config

NOW=$(date)
>&2 echo [ $NOW ] Running 1_evaluate_volume.sh
if [[ "$SYSNAME" == "katmai" ]] || [[ "$SYSNAME" == "denali" ]]; then
    >&2 echo Please enter sudo password
    sudo bash ./1_evaluate_volume.sh
else
    bash ./1_evaluate_volume.sh
fi
test_exit_status

NOW=$(date)
>&2 echo [ $NOW ] Running 2_process_stats.sh
bash ./2_process_stats.sh
test_exit_status

NOW=$(date)
>&2 echo [ $NOW ] Running 3_summarize_stats.sh
bash ./3_summarize_stats.sh
test_exit_status

NOW=$(date)
>&2 echo [ $NOW ] Running 4_plot_stats.sh
bash ./4_plot_stats.sh
test_exit_status

NOW=$(date)
>&2 echo [ $NOW ] Completed successfully
