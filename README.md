Scripts for performing analysis of filesystems - audit usage and trends

## Relevant `stat` options

From `man stat`

       --printf=FORMAT
              like --format, but interpret backslash escapes, and do not output a mandatory trailing newline; if you want a newline, include \n in FORMAT
The valid format sequences for files
       %A     access rights in human readable form
       %F     file type
       %G     group name of owner
       %h     number of hard links
       %m     mount point
       %n     file name
       %N     quoted file name with dereference if symbolic link
       %s     total size, in bytes
       %U     user name of owner
       %w     time of file birth, human-readable; - if unknown
       %x     time of last access, human-readable           # Access - the last time the file was read
       %y     time of last modification, human-readable     # Modify - the last time the file was modified (content has been modified)
       %z     time of last change, human-readable           # Change - the last time meta data of the file was changed (e.g. permissions)

Example commands, from e.g., https://superuser.com/questions/416308/how-to-list-files-recursively-and-sort-them-by-modification-time
```
find . -type f -exec stat -f "%m%t%Sm %N" '{}' \;
```

What I want in order
       %n     file name
       %F     file type
       %s     total size, in bytes
       %U     user name of owner
       %w     time of file birth, human-readable; - if unknown
       %y     time of last modification, human-readable     # Modify - the last time the file was modified (content has been modified)
       %h     number of hard links

Core command:

find . -exec stat --printf="%n\t%F\t%s\t%U\t%w\t%y\t%h\n" '{}' \;


# Evaluating /diskmnt/Projects/cptac

```
tmux
time bash 1_evaluate_fs.sh /diskmnt/Projects/cptac > dat/Projects.cptac.FS.dat
```

This exits with,
```
    Processing /diskmnt/Projects/cptac
    find: ‘./GDC_import/data/ZZ-test/logs’: Permission denied

    real    0m36.242s
    user    0m4.998s
    sys     0m13.349s
```
-> the permission error was not fatal.  
Results in 8923 entries

# TODO: output file should have real path of where it starts perhaps in comment
* count number of files in directory and their cumulative sizes
* treat .gz extension as special, and get the prior suffix, so distinguish between .vcf.gz and .fa.gz

o


