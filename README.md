# FSAudit: analyze and visualize filesystem usage

Notes here for multi-volume version of [FSAudit](https://github.com/ding-lab/FSAudit)

Past multi-volume work has been on MGI here: /gscuser/mwyczalk/projects/FSAudit/FSAudit.dev/FSAudit/multi-run

## Overview

Processing proceeds in these steps:
1. Evaluate volume.  Traverse entire volume (essentially `find | stat`) obtain information about all files in a specified filesystem. Writes `rawstat` file.
    * May be run `sudo` to provides complete information for all files regardless of permissions
2. Process stats. Secondary analysis of above data, writes `filestat` file
3. Summarize stat.  Merge above data according to owner and extension, writes `summary` file
4. Plot stats. Generate visualization figures

## Installation

This package requires python 3, GNU parallel, and R packages plyr and ggplot2.  

This can be managed with [Conda](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf)

## VolumeList

The VolumeList file contains the following two fields for every volume to be audited, tab-separated:
* `VOLUME_NAME`: Short name of system and volume, used for filenames 
* `VOLUME`: This is the base path we are analyzing 

Example VolumeList.dat file:
```
MGI.gc2500  /gscmnt/gc2500/dinglab
MGI.gc2508  /gscmnt/gc2508/dinglab
MGI.gc2509  /gscmnt/gc2509/dinglab
```


## Run notes

1. Create `config/VolumeList.dat`
* `tmux new -s FSAudit` - Optional call to start `tmux`. This is useful because run is time consuming
* If on MGI, `0_start_MGI_docker.sh`

To debug and test processing, run in dryrun mode and only the first one.
`bash 1_start_runs.sh -d1` will show the call to process_FS.sh, and
`bash 1_start_runs.sh -dd1` shows processing of individual steps

To run all with four jobs at a time,
```
bash 1_start_runs.sh -J 4 
```

### MGI-specific
On MGI, use conda environment `p3R`.  [Conda cheat sheet](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf)

`conda activate p3R`

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
