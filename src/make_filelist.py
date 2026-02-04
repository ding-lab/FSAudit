# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

import argparse
import sys
import gzip
import pandas as pd
from pathlib import Path


# https://stackoverflow.com/questions/5574702/how-do-i-print-to-stderr-in-python
# Usage: eprint("Test")
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


# rawstat columns
#     1  file_name   /rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/44421b45-a0db-4525-8c4e-c6aff0398cad/80a6e8b4-9a1d-470c-8529-e21151a864bc_wxs_gdc_realn.bam.bai
#     2  file_type   regular file
#     3  file_size   4642216
#     4  owner_name  estorrs
#     5  time_birth  -
#     6  time_access 2025-04-02 14:32:21.316975250 -0500
#     7  time_mod    2022-01-13 08:20:48.384607000 -0600
#     8  hard_links  1

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
def process_rawstat(rawstat_fn, cached_md5, primary_list):
    print(f"file_name\tfile_size\towner_name\ttime_mod\tmd5\ttag")
    cached_count, large_count = 0, 0
    with gzip.open(rawstat_fn, mode='rt') as rawstat:
        for i, line in enumerate(rawstat):
            if i == 0:  # skip the header line
                continue
#            eprint("Line %d: %s" % (i, line))
            try:
                file_name, file_type, file_size, owner_name, time_birth, time_access, time_mod, hard_links = line.split("\t")
            except ValueError:
                eprint("Skipping malformed line %d: %s" % (i, line))
            if file_type != "regular file": continue

            tags = []
            md5 = "."
            if file_name in cached_md5:
#                eprint(f"DEBUG: cached md5  found for {file_name}")
                md5 = cached_md5[file_name]
                cached_count += 1

            if int(file_size) > default_large_size:
#                eprint("DEBUG: large size")
                tags.append("large")
                large_count += 1
            
            file_path = Path(file_name)
            for p in file_path.parents:
                if str(p) in primary_list:
#                    eprint(f"DEBUG: {str(p)} is primary")
                    tags.append("primary")

            if len(tags) > 0:
                tag_string = ";".join(tags)
            else:
                tag_string = ""

            print(f"{file_name}\t{file_size}\t{owner_name}\t{time_mod}\t{md5}\t{tag_string}")
    eprint(f"Found {cached_count} cached md5s out of {large_count} large files")

            
# cached_fn is assumed to be direct output from `md5sum` command, with a 32-character md5 hash, followed by two space,
# then the complete path
def get_cached_md5(cached_fn, rdcw_swap):
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

# we are transitioning from an old school filelist format to a new one.
# old school, with no header and no tag column
# new: header line, has tag column
# Create a hash cached[filename] = md5 for those filenames which have an md5
def get_md5_filelist(filelist_gz, rdcw_swap):
    cached = {}

    with gzip.open(filelist_gz, mode='rt') as filelist:
        for i, line in enumerate(filelist):
            if i == 0:  # skip the header line
                continue
#            eprint("Line %d: %s" % (i, line))
            if len(line) == 1:      # skip blank lines
                continue
#            file_name, file_size, owner_name, time_access, time_mod, md5 = line.split("\t")
            file_name, file_size, owner_name, time_mod, md5, tag = line.split("\t")
            if md5 == ".":
                continue
            if rdcw_swap:
                if file_name.startswith("/rdcw"):
                    file_name = file_name.replace("/rdcw", "/storage1")
            cached[file_name] = md5.rstrip()
    return cached

# if rdcw_swap = true, cached paths starting with "/rdcw" are replaced with "/storage1"
#   this may be necessary due to a weirdness in normalizing paths on storage1
def get_md5(cached_md5, filelist_gz, rdcw_swap=False):

    # provide multiple ways of reading in cached md5: from output of `md5run` and from a previous filelist which has md5 information
    cachedA, cachedB = {}, {}
    if cached_md5:
        eprint(f"Reading md5s from md5sum output {args.cached_md5}")
        cachedA = get_cached_md5(args.cached_md5, rdcw_swap)
    if filelist_gz:
        eprint(f"Reading md5s from filelist {args.filelist_gz}")
        cachedB = get_md5_filelist(args.filelist_gz, rdcw_swap)
    # https://stackoverflow.com/questions/38987/how-do-i-merge-two-dictionaries-in-a-single-expression-in-python
    cached = {**cachedA, **cachedB}
    return cached

def get_primary(primary_fn):
    primary = []
    with open(primary_fn, mode='rt') as primary_list:
        for line in primary_list:
            primary.append(line.rstrip())
    return primary

if __name__ == "__main__":

    # TODO: add option to exclude certain directories from list

    default_minsize = 1024**3    # 1gb 
    parser = argparse.ArgumentParser(description="Create a filelist from a rawstat file")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-m", dest="cached_md5", help="Provide md5 from output of `md5sum` ")
    parser.add_argument("-M", dest="filelist_gz", help="Provide md5 in a filelist gz file ")
    parser.add_argument("-p", dest="primary", help="Input list of primary data")
#    parser.add_argument("-o", "--output", dest="outfn", help="Output filelist ")
    parser.add_argument(dest="rawstat", help="Input rawstat file")
    parser.add_argument("-s", "--rdcw_swap", action="store_true", help="cached md5 paths starting with \'/rdcw\' are replaced with \'/storage1\'")

    args = parser.parse_args()

    cached = get_md5(args.cached_md5, args.filelist_gz, args.rdcw_swap)
    

    if args.primary:    
        eprint(f"Reading primary list {args.primary}")
        primary = get_primary(args.primary)
    else:
        primary = []

    eprint(f"Processing {args.rawstat}...")
    process_rawstat(args.rawstat, cached, primary)



