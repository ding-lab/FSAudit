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

## TODO

* when writing raw files, can write out dirlist and filelist at the same time.  rawstat format may even be optional
* We may be interested in evaluating only those dirs or files which are older than X years old



