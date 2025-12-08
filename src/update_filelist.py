# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

import argparse
import sys
import gzip
import pandas as pd
from pathlib import Path

# this script updates filelist data with additional information from md5sum run.  The idea is it can be run after md5sum calculations
# to update the filelist file.  It is based on make_filelist.py, but reads in filelist rather than rawstat files
# it does not at this time update any tags

# https://stackoverflow.com/questions/5574702/how-do-i-print-to-stderr-in-python
# Usage: eprint("Test")
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# output columns
# file_name 
# file_size
# owner_name
# time_mod
# md5   -> from cached_md5, "." if unknown
# tag   -> primary, large, skip_md5

# mark files >1Gb as "large"
default_large_size = 1024**3    # 1gb 

# prints out filestat lines
def process_filelist(filelist_fn, cached_md5):
    print(f"file_name\tfile_size\towner_name\ttime_mod\tmd5\ttag")
    with gzip.open(filelist_fn, mode='rt') as filelist:
        for i, line in enumerate(filelist):
            if i == 0:  # skip the header line
                continue
#            eprint("Line %d: %s" % (i, line))
            try:
                file_name, file_size, owner_name, time_mod, md5, tag = line.split("\t")
            except ValueError:
                eprint("Skipping malformed line %d: %s" % (i, line))

            if file_name in cached_md5:
                md5 = cached_md5[file_name]
                eprint(f"Adding {file_name} : {md5}")

            print(f"{file_name}\t{file_size}\t{owner_name}\t{time_mod}\t{md5}\t{tag}")

            
# cached_fn is assumed to be direct output from `md5sum` command, with a 32-character md5 hash, followed by two space,
# then the complete path
# if rdcw_swap = true, cached paths starting with "/rdcw" are replaced with "/storage1"
#   this may be necessary due to a weirdness in normalizing paths on storage1
def get_cached_md5(cached_fn, rdcw_swap=False):
    cached = {}
    with open(cached_fn, mode='rt') as cached_f:
        for i, line in enumerate(cached_f):
            md5=line[:32]
            file_name = line[34:].rstrip()
            if rdcw_swap:
                if file_name.startswith("/rdcw"):
                    file_name = file_name.replace("/rdcw", "/storage1")
            cached[file_name] = md5
    return cached

if __name__ == "__main__":

    # TODO: add option to exclude certain directories from list

    parser = argparse.ArgumentParser(description="Update a filelist with md5 information")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-m", dest="cached_md5", help="Input cached md5 list")
    parser.add_argument(dest="filelist", help="Input filelist file")

    args = parser.parse_args()

    if args.cached_md5:
        eprint(f"Reading cached md5s {args.cached_md5}")
        cached = get_cached_md5(args.cached_md5, True)
    else:
        cached = {}

    eprint(f"Processing {args.filelist}...")
    process_filelist(args.filelist, cached)



