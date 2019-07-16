# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Ding Lab, Washington University School of Medicine

# Usage: Rscript plot_FSAudit.R [options] data.fn plot.size.fn plot.count.fn

# Args:
# -v: verbose
# -N N: retain top N entries.  Default 250
# -h height: plot height. Default 6
# -w width: plot width. Default 18
# -L vol_name: name of volume being processed, used for title
# -D date: string representing date, used for title

library(ggplot2)
library(plyr)

# Return the command line argument associated with a given flag (i.e., -o foo),
# or the default value if argument not specified.
# Note that this will break if an argument is not supplied after the flag.
get_val_arg = function(args, flag, default) {
    ix = pmatch(flag, args)
    if (!is.na(ix)){ val = args[ix+1] } else { val = default }
    return(val)
}

# Return boolean specifying whether given flag appears in command line (i.e., -o),
get_bool_arg = function(args, flag) {
    ix = pmatch(flag, args)
    if (!is.na(ix)){ val = TRUE } else { val = FALSE }
    return(val)
}

# Usage:
#   args = parse_args()
#   print(args$disease.filter)
parse_args = function() {
    args = commandArgs(trailingOnly = TRUE)

    # optional arguments
    verbose = get_bool_arg(args, "-v")
    top.N = as.numeric(get_val_arg(args, "-N", 250))
    height = as.numeric(get_val_arg(args, "-h", 6))
    width = as.numeric(get_val_arg(args, "-w", 18))
    vol.name = get_val_arg(args, "-L", "volume")
    date = get_val_arg(args, "-D", "date")

    # mandatory positional arguments.  These are popped off the back of the array, last one listed first.
    plot.count.fn = args[length(args)]; args = args[-length(args)]
    plot.size.fn = args[length(args)]; args = args[-length(args)]
    data.fn = args[length(args)]; args = args[-length(args)]

    val = list( 'plot.size.fn'=plot.size.fn, 'plot.count.fn'=plot.count.fn, 'verbose'=verbose, 'data.fn'=data.fn, 'top.N'=top.N,
                'height' = height, 'width' = width, 'vol.name'=vol.name, 'date'=date)

    if (val$verbose) { print(val) }
    return (val)
}

args = parse_args()

# Script based on FSAudit.Rmd

rFSA<-read.csv(args$data.fn, sep="\t")
rFSA$cumulative_size_Tb = rFSA$cumulative_size / (1024 * 1024 * 1024 * 1024)
rFSA$ext_short = substring(rFSA$ext, first=1, last=16)   # Limit extension to first 16 characters for plotting

rFSA.size=head(arrange(rFSA,desc(cumulative_size_Tb)),n=args$top.N)
title_text = sprintf("%s - %s - File size - Top %d", args$vol.name, args$date, args$top.N)
p <- ggplot(data=rFSA.size)
p <- p + geom_point(aes(x=ext_short, y=owner_name, size=cumulative_size_Tb)) + scale_size_area(name="Cumulative Size [Tb]")
p <- p + ggtitle(title_text) + ylab("Owner Name") + xlab("File Extension")
p <- p + theme_bw()+ theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1), panel.grid.minor=element_blank(),
           panel.grid.major=element_blank())
cat(sprintf("Saved to %s\n", args$plot.size.fn))
ggsave(args$plot.size.fn, height=args$height, width=args$width, useDingbats=FALSE)
unlink("Rplots.pdf")


rFSA.count=head(arrange(rFSA,desc(count)),n=args$top.N)
title_text = sprintf("%s - %s - File count - Top %d", args$vol.name, args$date, args$top.N)

p <- ggplot(data=rFSA.count)
p <- p + geom_point(aes(x=ext_short, y=owner_name, size=count)) + scale_size_area(name="File Count")
p <- p + ggtitle(title_text) + ylab("Owner Name") + xlab("File Extension")
p <- p + theme_bw() + theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1), panel.grid.minor=element_blank(),
           panel.grid.major=element_blank())

cat(sprintf("Saved to %s\n", args$plot.count.fn))
ggsave(args$plot.count.fn, height=args$height, width=args$width, useDingbats=FALSE)
unlink("Rplots.pdf")

