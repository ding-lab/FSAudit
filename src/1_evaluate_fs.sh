# Collect statistics about all files in all subdirectories of ROOT_DIR

# USAGE
# 1_evaluate_fs.sh ROOT_DIR 

# OUTPUT - columns
#       %n     file name
#       %F     file type
#       %s     total size, in bytes
#       %U     user name of owner
#       %y     time of last modification, human-readable     # Modify - the last time the file was modified (content has been modified)
#       %h     number of hard links


ROOT_DIR=$1

if [[ ! -d $ROOT_DIR ]]; then
    >&2 echo ERROR: $ROOT_DIR does not exist
    exit 1
fi

>&2 echo Processing $ROOT_DIR
cd $ROOT_DIR
RDA=$(pwd -P)   # Absolute path

printf "# file_name\tfile_type\ttotal_size\towner_name\ttime_mod\thard_links\n"
printf "# ROOT_DIR $RDA\n"
find . -exec stat --printf="%n\t%F\t%s\t%U\t%y\t%h\n" '{}' \;
