Scripts for performing analysis and visualization of filesystem usage

# Overview

Analysis currently consists of several scripts run to analyze a filesystem, followed by a visualization step which generates figures.

# How to run

## make data directory and soft link to it
$ mkdir /storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/mwyczalkowski.20250815
$ ln -s /storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/mwyczalkowski.20250815 dat

## Edit config.sh

## Running scripts

### 1_start_runs.sh

Launch this from tmux.  Not launching with bsub.  Currently need to copy/paste CMD, should move src/launch_stat_fs.sh contents into
1_start_runs.sh

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
       %w     time of file birth, human-readable; - if unknown - new in V3
       %x     time of last access, human-readable; new in V3
       %y     time of last modification, human-readable    
       %h     number of hard links

```

## TODO

* Create real documentation
  * describe dirmap

* Step 1 should be to write out dirlist and filelist, with raw output optional
* Steps 3 and 4 should be merged, essentially submitting script in 4 using bsub from 3


* We may be interested in evaluating only those dirs or files which are older than X years old


Dirtree:
https://github.com/emad-elsaid/dirtree
gem install dirtree 
-> needs gem
conda install gem
