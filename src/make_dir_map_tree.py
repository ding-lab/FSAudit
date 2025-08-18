# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

# We will write all directories and their size, calculated as the size of all files under them
# Current implementation builds an internal directory tree structure then loops over all files

import sys, os, gzip, math, datetime

# https://anytree.readthedocs.io/en/stable/intro.html
#from anytree import Node, RenderTree, Resolver, Walker
import anytree


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def add_dir_to_tree(dirpath, root):
# https://anytree.readthedocs.io/en/stable/api/anytree.node.html#anytree.node.node.Node
    parent = root
    for d in dirpath.split("/")[2:]:    # d is direcory name.  nd is node associated with d
        nd = None
        for c in parent.children:   # consider using resolver
            if c.name == d:
                nd = c
                break
        if nd is None:
            nd = anytree.Node(d, parent=parent, dirsize=0, dirsize_user={})
        parent = nd            

# keep per-owner statistics only if owner_name is specified
def add_file_to_tree(filepath, filesize, owner_name, root, resolver, walker):
# use Resolver to get leaf directory
    dirpath = os.path.dirname(filepath)
#    eprint("path, dirpath, size = %s, %s, %d" % (filepath, dirpath, filesize))
#    eprint("root = %s" % root)
    leaf = resolver.get(root, dirpath)
#    eprint("leaf = %s" % leaf)

    # https://anytree.readthedocs.io/en/stable/api/anytree.walker.html
    for n in walker.walk(root, leaf)[2]:
        n.dirsize += filesize
        if owner_name is not None:
            if owner_name not in n.dirsize_user:
                n.dirsize_user[owner_name] = filesize
            else:
                n.dirsize_user[owner_name] += filesize
            

# use walker to go from root to leaf dir, and add filesize to each
#     1 file_name   /rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl
#     4 owner_name  m.wyczalkowski
#     5 time_mod    2023-02-01 18:11:36.000000000 -0600
def make_dirtree(fn, rootNode):
    with gzip.open(fn, mode='rt') as dirlist:
        for i, line in enumerate(dirlist):
#            eprint("Line %d: %s" % (i, line))
            dirpath = line.split("\t")[0]
            add_dir_to_tree(dirpath, rootNode)

#     1	file_name	/rdcw/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/20230427.SW_vs_TD/dat/call-rescuevaffilter_pindel/rescuevaffilter.cwl/b9ea6316-ce5e-401f-9ff8-dc181ed7db4d/call-somatic_vaf_filter_A/execution/rc
#     3	file_size	2
#     4	owner_name	m.wyczalkowski
#     5	time_mod	2023-02-01 18:11:47.000000000 -0600
def parse_files(fn, rootNode, by_owner=False):
    resolver = anytree.Resolver()
    walker = anytree.Walker()
    with gzip.open(fn, mode='rt') as filelist:
        for i, line in enumerate(filelist):
#            eprint("Line %d: %s" % (i, line))
            try:
                tok = line.split("\t")
                filepath = tok[0]# .lstrip("/")
                filesize = int(tok[1])
                owner_name = tok[2] if by_owner else None

                add_file_to_tree(filepath, filesize, owner_name, rootNode, resolver, walker)
            except IndexError: # this happens for malformed filenames which contain newlines or tabs.  Just ignore them
                eprint("Error caught in %s line %d\n\t%s\nContinuing" % (fn, i, line))

# https://stackoverflow.com/questions/5194057/better-way-to-convert-file-sizes-in-python
def convert_size(size_bytes, ndigits=2):
   if size_bytes == 0:
       return "0B"
   size_name = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
   i = int(math.floor(math.log(size_bytes, 1024)))
   p = math.pow(1024, i)
   s = round(size_bytes / p, ndigits)  # None for int
   return "%s %s" % (s, size_name[i])


# write out dirmap for all files
# optionally, write out per-user dirmap
#   filename for per-user dirmap is same as for dirmap but with username appended before extension
def write_all_dirtrees(fn, rootNode, by_owner=None):
    # write dirmap for all users

    write_dirtree(fn, rootNode)

    # Optionally, write it for all owners individually
    if by_owner:
        users = list(rootNode.dirsize_user.keys())  # for some reason rootNode does not have any information with it
        fn_base, fn_ext = os.path.splitext(fn)
        if (fn_ext == ".gz"):
            fn_base, fn_ext = os.path.splitext(fn_base)
            fn_ext = "%s.gz" % fn_ext

        eprint("fn_base = %s fn_ext = %s" % (fn_base, fn_ext))
        for u in users:
            if "/" in u:        # sometimes see weird filenames which messes up usernames
                eprint("WARNING: possibly weird username %s.  Skipping" % u)
            fnu = "%s-%s%s" % (fn_base, u, fn_ext)
            # confirm that filename using username is not weird: https://stackoverflow.com/questions/8686880/validate-a-filename-in-python
            if not os.path.normpath(fnu).startswith(fn_base):
                eprint("WARNING: invalid path %s.  Skipping" % fnu)

            eprint("Saving to %s" % fnu)
            write_dirtree(fnu, rootNode, user=u)

# We want to write out all non-zero size directories along with their sizes.  Also, we write out a new directory tree where each directory name
# is replaced by that name with directory size appended, e.g. "/foo/bar" becomes "/foo 46MB/bar 256KB".  This is intended for visualization purposes
def write_dirtree(fn, rootNode, user=None):
    eprint("[%s] Writing compressed dirtree to %s for user %s" % (datetime.datetime.now(), fn, str(user)))
#    with open(fn,"w") as f:            # this for text file output
    with gzip.open(fn, "wt") as f:    # this for gzip file output
        for i, n in enumerate(anytree.LevelOrderIter(rootNode)):
            if user is None:
                dirsize = n.dirsize
                vp = "/".join([""] + ["%s %s" % (str(nn.name), convert_size(nn.dirsize, None)) for nn in n.path])
            else:
                dirsize = 0 if user not in n.dirsize_user else n.dirsize_user[user]
                vp = "/".join([""] + ["%s %s" % (str(nn.name), convert_size(0 if user not in nn.dirsize_user else nn.dirsize_user[user], None)) for nn in n.path])
            if dirsize == 0: continue
            # https://anytree.readthedocs.io/en/stable/api/anytree.node.html#anytree.node.nodemixin.NodeMixin.path
            p = "/".join([""] + [str(nn.name) for nn in n.path])
            f.write("%s\t%d\t%s\n" % (p, dirsize, vp))

# write information about the per-user usage of the filesystem to ownerlist
def write_file_stats(filesize, fn):
    eprint("[%s] Writing filestats per owner to %s" % (datetime.datetime.now(), fn))
    with open(fn,"w") as f:            # this for text file output
        f.write("owner_name\tfile_size\n")
        for n in filesize:
            f.write("%s\t%d\n" % (n, filesize[n]))

def main():
    from optparse import OptionParser
    usage_text = """usage: %prog [options] ...
        Process list of generated by stat of file options
        """

    parser = OptionParser(usage_text, version="$Revision: 1.2 $")
    parser.add_option("-e", dest="dirlist", help="List of directories")
    parser.add_option("-f", dest="filelist", help="List of files")
    parser.add_option("-o", dest="outfn", default="stdout", help="Output filename")
    parser.add_option("-u", dest="by_owner", action="store_true", help="Retain statistics for per-user dirmaps, and write them out ")
    parser.add_option("-U", dest="ownerlist", help="Generate a summary list of files and disk use per user and write to this file")
#    parser.add_option("-O", dest="ownerdirlist", help="write out usage per user")

# writing out a per-owner list of dir3 files is supported as a boolean
# accumulate per-owner size information at the node level only if user requests, then write it all out

    (options, params) = parser.parse_args()

#        eprint("[%s]: tree depth = %d: %d files" % (datetime.datetime.now(), L, len(dirsL.index) ))
    # not clear how to do this with no assumptions about root dir
    # dirsize holds cumulative sum of all files in a directory
    # dirsize_user is a cumulative sum of all files per user
    rootNode = anytree.Node("rdcw", dirsize=0, dirsize_user={})
    eprint("[%s] Making dirlist from %s" % (datetime.datetime.now(), options.dirlist))
    make_dirtree(options.dirlist, rootNode)

    eprint("[%s] Parsing files in %s" % (datetime.datetime.now(), options.filelist))
    parse_files(options.filelist, rootNode, options.by_owner)

    rootNode.dirsize = rootNode.children[0].dirsize
    rootNode.dirsize_user = rootNode.children[0].dirsize_user
    
#    eprint(anytree.RenderTree(rootNode, maxlevel = 6))

    write_all_dirtrees(options.outfn, rootNode, options.by_owner)

    if options.ownerlist:
        write_file_stats(rootNode.dirsize_user, options.ownerlist)


if __name__ == '__main__':
    main()

