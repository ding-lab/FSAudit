#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Obtain details on all files in filesystem and write raw stat report

Usage:
  stat_fs.sh [options] ROOT_DIR 

Options:
-h: Print this help message
-o OUT_GZ: output filename.  If ends in .gz, output will be compressed

Uses `find` and `stat` to get all information about files in filesystem
By default, raw stat report written to stdout, use -o to write to file
EOF

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":ho:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
#    d)  # example of binary argument
#      >&2 echo "Dry run"
#      CMD="echo"
#      ;;
    o) # writing to output file.  Test if extension is .gz, per https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
      OUT_FN=$OPTARG
      FN=$(basename -- "$OUT_FN")
      EXT="${FN##*.}"
      if [ "$EXT" == "gz" ]; then
          DO_GZ=1
          >&2 echo "Writing to compressed $OUT_FN"
      else
          >&2 echo "Writing to $OUT_FN"
      fi
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG"
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument."
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))


if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage: stat_fs.sh ROOT_DIR 
    exit 1
fi

# Collect statistics about all files in all subdirectories of ROOT_DIR
# USAGE: call_find_stats ROOT_DIR 
# OUTPUT - columns
#       %n     file name
#       %F     file type
#       %s     total size, in bytes
#       %U     user name of owner
#       %w     time of file birth, human-readable [time_birth]
#       %x     time of last access, human-readable [time_access]
#       %y     time of last data modification, human-readable [time_mod]
#       %h     number of hard links

function call_find_stat {
    RD=$1

    if [[ ! -d $RD ]]; then
        >&2 echo ERROR: $RD does not exist
        exit 1
    fi

    RDA=$(readlink -f $RD)

    printf "file_name\tfile_type\tfile_size\towner_name\ttime_birth\ttime_access\ttime_mod\thard_links\n"

#   -xdev  Don't descend directories on other filesystems.
    find $RDA -xdev -exec stat --printf="%n\t%F\t%s\t%U\t%w\t%x\t%y\t%h\n" '{}' \;
}

ROOT_DIR=$1

if [[ ! -d $ROOT_DIR ]]; then
    >&2 echo ERROR: $ROOT_DIR does not exist
    exit 1
fi

NOW=$(date)
>&2 echo [ $NOW ] : Processing $ROOT_DIR

if [ -z $OUT_FN ]; then
    call_find_stat $ROOT_DIR 
elif [ -z $DO_GZ ]; then
    call_find_stat $ROOT_DIR > $OUT_FN
else
    call_find_stat $ROOT_DIR | gzip > $OUT_FN
fi

NOW=$(date)
>&2 echo [ $NOW ] : Done.
