Scripts for performing analysis and visualization of filesystem usage

# Overview

Analysis currently consists of several scripts run to analyze a filesystem, followed by a visualization step which generates figures.

* Edit `FSAudit.config` to define variables used in analysis and plotting
* `tmux new -s FSAudit` - Optional call to start `tmux`. This is useful because run is time consuming
* If on MGI, `0_start_MGI_docker.sh`
* `sudo 1_evaluate_volume.sh` - initial call which obtains information about all files in a specified filesystem, writes `rawstat` file
    * the `sudo` is optional and may not be available, but provides more complete information for cases where data is not accessible as user
* `2_process_stats.sh`   - Secondary analysis of above data, writes `filestat` file
* `3_summarize_stats.sh` - Merge above data according to owner and extension, writes `summary` file
* `4_plot_stats.sh` - generate visualization figures

The following plots are generated
![](doc/gc.2737.20190612.FileCount.png)
![](doc/gc.2737.20190612.FileSize.png)

All output is written to `./dat`, `./logs`, `./img`

## Handy analysis

Get details for given extension and user:
```
zcat /gscmnt/gc3020/dinglab/mwyczalk/gc2737.20190612.filestat.gz | awk -v FS="\t" '{if ($3 == ".chr20" && $6 == "rmashl") print}'
```

# Background

## Relevant `stat` options

From `man stat`

       --printf=FORMAT
              like --format, but interpret backslash escapes, and do not output a mandatory trailing newline; if you want a newline, include \n in FORMAT

What I want in order
```
       %n     file name
       %F     file type
       %s     total size, in bytes
       %U     user name of owner
       %y     time of last modification, human-readable    
       %h     number of hard links
```
## Installation

This package requires python 3.  R packages which need to be installed: plyr, ggplot2
