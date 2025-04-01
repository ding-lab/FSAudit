Scripts for performing analysis and visualization of filesystem usage

# Overview

Analysis currently consists of several scripts run to analyze a filesystem, followed by a visualization step which generates figures.


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

# TODO and development notes
See notes ../FSAudit-pre2025/README.project.md

## TODO

* All output gets written into dat/VOLUME.TIMESTAMP/
* get access time as well as create time - parseFS
* make parsing bsub-based on compute1.  Simplify it
  * get rid of parallel processing, this should be done at the highest level if at all
* get rid of different stages in the parsing program.  Each script does one thing
  * At this point, step 1 fails at the processing step, out of memory for dinglab
* src/process_FS.sh should not have any python calls in it
* when writing raw files, can write out dirlist and filelist at the same time.  rawstat format may even be optional

* We may be interested in evaluating only those dirs or files which are older than X years old

## V2 launch process

* 1_start_runs.sh
* this runs src/process_FS_parallel.sh
  * Loops over list of volume names and has a bunch of steps
  * Calls src/process_FS.sh for each volume
    * calls src/evaluate_fs.py 
      * Renamed src/stat_fs.sh
      * calls stat on all files and writes raw data
      * writes rawstat.gz file
    * calls src/parse_fs.py
      * Retains only regular files
      * extracts dirname, filename, extension
      * writes filestat.gz file
      * This is no longer used
* 2_make_dirlist_filelist.sh
  * Reads rawstat file
  * Writes dirlist and filelist
* 4_make_dirmap3-user.sh
  * Calls src/make_dir_map_tree.py
  * Writes all directories and their size, calculated as the size of all files under them


Changes to make:
* Run src/stat_fs.sh as bsub command for each volume of interest
  * do not use parallel    
  * use launch model here: /home/m.wyczalkowski/src/templates/launch_bsub


## Run m.wyczalkowski-20250331

Because of a bug that was later fixed, time of last access is incorrect.


