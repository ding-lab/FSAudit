# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

import argparse
import sys
import pandas as pd


#FILELIST=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250909/dinglab.20250909.filelist.tsv.gz
#PAST_MD5=/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20250728/dinglab.20250728.filelist.gt_1Gb_md5.tsv
#Data columns (not labeled in datafile)
#* file_name   /rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#* file_size   2
#* owner_name  m.wyczalkowski
#* time_access 2025-04-02 14:32:21.316975250 -0500
#* time_mod    2023-02-01 18:11:47.000000000 -0600
#* [md5] - only in PAST_MD5 file
#
#The goal is to find all files which do not have an MD5 listed, with matching by complete paths - would be good to compare filesizes too as a sanity check



# https://stackoverflow.com/questions/5574702/how-do-i-print-to-stderr-in-python
# Usage: eprint("Test")
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


# Pandas merging 101
# https://stackoverflow.com/questions/53645882/pandas-merging-101
# filelist is left
def get_uncached_files(filelist, cached):
    # this retains the entries which do have md5
    # merged = filelist.merge(cached[ ['file_name', 'md5'] ], on="file_name")

    # right-excluding
    uncached = filelist.merge(cached[ ['file_name', 'md5'] ], on="file_name", how="left", indicator=True).query('_merge == "left_only"').drop( ['_merge'], axis=1)
    uncached['md5'] = "uncached"

    return uncached
    

if __name__ == "__main__":

    # TODO: add option to exclude certain directories from list

    default_minsize = 1024**3    # 1gb 
    parser = argparse.ArgumentParser(description="Identify files for which to evaluate MD5 for")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-m", dest="cached", help="Input cached md5 file list")
    parser.add_argument("-o", "--output", dest="outfn", help="Output md5 file list")
    parser.add_argument("-s", "--minsize", dest="minsize", default=default_minsize, help="Discard all files below this size from worklist")
    parser.add_argument(dest="filelist", help="Input file list")

    args = parser.parse_args()

    col_names = ["file_name", "file_size", "owner_name", "time_access", "time_mod"]
    eprint(f"Reading file list {args.filelist}")
    filelist = pd.read_csv(args.filelist, sep="\t", names=col_names)
    filelist = filelist[ filelist['file_size'] >= args.minsize ]

    col_names_md5 = ["file_name", "file_size", "owner_name", "time_access", "time_mod", "md5"]
    if args.cached:
        eprint(f"Reading cached md5s {args.cached}")
        cached = pd.read_csv(args.cached, sep="\t", names=col_names_md5)
    else:
        eprint(f"No cached md5s passed")
        cached = pd.DataFrame(columns=col_names_md5)


    uncached = get_uncached_files(filelist, cached)
    
    eprint(f"Writing to {args.outfn}")
    uncached.to_csv(args.outfn, sep="\t", index=False)


