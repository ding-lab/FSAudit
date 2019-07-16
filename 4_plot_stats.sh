source FSAudit.config

DAT="$DATD/${VOLNAME}.${TIMESTAMP}.summary.dat"
FS_PLOT="$IMGD/${VOLNAME}.${TIMESTAMP}.FileSize.pdf"
FC_PLOT="$IMGD/${VOLNAME}.${TIMESTAMP}.FileCount.pdf"

# -V vol_name: name of volume being processed, used for title
# -D date: string representing date, used for title

echo Rscript src/plot_FSAudit.R -L $VOL -D $TIMESTAMP $DAT $FS_PLOT $FC_PLOT

