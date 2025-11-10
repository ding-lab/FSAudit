# Print out dirlist for a given filename
import argparse

f="/rdcw/fs1/dinglab/Active/Projects/TCGA-TGCT/Primary/wxs/44421b45-a0db-4525-8c4e-c6aff0398cad/logs/80a6e8b4-9a1d-470c-8529-e21151a864bc_wxs_gdc_realn.bam.parcel"

def print_parent_dirs(f):
    t=f.split(sep="/")
    out=[]  # this is the list of parent paths
    p=[]    # this is the built up path
    for i in t[:-1]:
        p.append(i)
        if (p != [""]):
            out.append("/".join(p))
    return out

parser = argparse.ArgumentParser()
parser.add_argument("filepath")
parser.add_argument("--user", default="user")
parser.add_argument("--timestamp", default="1/1/2025")
parser.add_argument("--header", action="store_true")
args = parser.parse_args()

paths = print_parent_dirs(args.filepath)

if args.header:
    print("\t".join(["file_name", "owner_name", "time_mod"]))

for p in paths:
    print("\t".join([p, args.user, args.timestamp]))
