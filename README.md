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
       %y     time of last modification, human-readable    
       %h     number of hard links
```
