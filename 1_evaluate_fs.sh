# Collect statistics about all files in ROOT_DIR and process using src/parse_fs.py

# USAGE
# 1_evaluate_fs.sh ROOT_DIR OUT_GZ

if [ "$#" -ne 2 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage: 1_evaluate_fs.sh ROOT_DIR OUT_GZ
    exit
fi

ROOT_DIR=$1
OUT_GZ=$2

if [[ ! -d $ROOT_DIR ]]; then
    >&2 echo ERROR: $ROOT_DIR does not exist
    exit 1
fi

>&2 echo Processing $ROOT_DIR, writing to $OUT_GZ

bash src/evaluate_fs.sh $ROOT_DIR | python parse_fs.py | gzip > $OUT_GZ
>&2 echo Done.
