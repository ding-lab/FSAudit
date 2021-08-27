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
Also require GNU parallel

### Debug

This requires python 3.  Python 2 yields errors like this:
```
TypeError: open() got an unexpected keyword argument 'encoding'
```

# Development

Example column values

## MGI.gc2500.20210825.rawstat.gz
```
     1	# file_name	/gscmnt/gc2500/dinglab/in/CTSP/1bcb893f-206f-467f-93f0-69f7b33dcc8f/9b7b7b0a-3d2c-4137-9f49-5ccfbdb90c64_wxs_gdc_realn.bam
     2	file_type	regular file
     3	file_size	35926511484
     4	owner_name	rmashl
     5	time_mod	2021-05-10 21:00:45.000000000 +0000
     6	hard_links	1
```

## MGI.gc2500.20210825.filestat.gz
```
     1	# dirname	/gscmnt/gc2500/dinglab/in/CTSP/a3abf5b6-126a-4cb9-83d9-4300207c5bf2
     2	filename	2bbb943a-ab5c-48bb-a1a0-7c41db0812cc_wxs_gdc_realn.bam
     3	ext	.bam
     4	file_type	regular file
     5	file_size	38327962760
     6	owner_name	rmashl
     7	time_mod	2021-05-10 18:46:15.000000000 +0000
     8	hard_links	1
```
TODO: add "volume_name" label to filestat.gz as given in VolumeList.dat


