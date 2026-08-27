process stat_filesystem {
    label 'dailybox'
    input:
    val vol_path

    output:
    path "rawstat.tsv.gz"

    script:
    """
    stat_fs.sh -o rawstat.tsv.gz ${vol_path}
    """
}

process make_filelist {
    label 'python3'
    input:
    path rawstat
    path primary_list
    path past_md5_fl

    output:
    path "filelistA.tsv.gz"

    script:
    """
    # -s: rdcw_swap.  Converts leading /rdcw to /storage1 to account for ris weirdness.  Typically necessary on compute1

    make_filelist.py -s -M ${past_md5_fl} -p ${primary_list} ${rawstat} | gzip > filelistA.tsv.gz
    """
}

process make_dirlist {
    label 'dailybox'
    input:
    path rawstat

    output:
    path "dirlist.tsv.gz"

    script:
    """
    make_dirlist.sh $rawstat
    """
}

process parse_dirs {
    label 'python3himem'
    publishDir "./results", pattern: "ownerlist.tsv"

    input:
    path dirlist
    path filelist

    output:
    path "dirmap3.tsv.gz", emit: dirmap_all
    path "ownerlist.tsv", emit: ownerlist
    path "dirmap3-*.tsv.gz", emit: dirmap_user

    script:
    """
    make_dir_map_tree.py -u -U ownerlist.tsv -e ${dirlist} -f ${filelist} -o dirmap3.tsv.gz -R storage1
    """
}

// TODO: pass N_parallel as a parameter
process evaluate_md5_parallel {
    label 'dailybox'
    input:
    path filelist
    val N_parallel

    output:
    path "md5-raw.txt"
    shell:
    '''
    zcat !{filelist} | awk 'BEGIN{FS="\\t";OFS="\\t"}{if ($6 ~ /large/ && $5 == "." ) print}' > md5-worklist.tsv
    cat md5-worklist.tsv | cut -f 1 | xargs -I "{}" -n 1 -P !{N_parallel} md5sum "{}" > md5-raw.txt
    '''
}

process update_filelist {
    label 'python3'
    publishDir './results'
    input:
    path md5raw
    path filelistA

    output:
    path "filelist.tsv.gz", emit: filelist
    path "filelist-md5.tsv.gz", emit: filelist_md5

    shell:
    '''
    update_filelist.py -m !{md5raw} !{filelistA} | gzip > filelist.tsv.gz

    # for convenience / speed, retaining a list of all files with MD5
    zcat filelist.tsv.gz | awk 'BEGIN{FS="\t";OFS="\t"}{if ($5 != ".") print}' | gzip > filelist-md5.tsv.gz
    '''
}

process make_dirtree {
    label 'dirtree'
    publishDir './results'
    input:
    path dirmap3 
    val lim

    output:
    path "dirmap3.html"

    shell:
    '''
    zcat !{dirmap3} | awk 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > !{lim}) print $3}' | /usr/local/bundle/bin/dirtree -o dirmap3.html
    '''

}


process make_dirtree_user {
    label 'dirtree'
    publishDir './results/dirtree-user'
    input:
    path dirmap3_user // - this should have all those files
    path ownerlist 
    val lim

    output:
    path "dirmap3-*.html"

    // Next make dirtree per user, showing all directories with >10Gb owned by that user
    shell:
    '''
    while read L; do
        U=$(echo "$L" | cut -f 1)
        if [ $U == "owner_name" ]; then
            continue
        fi

        DAT="dirmap3-$U.tsv.gz" # just gonna assume that's what this is calld

        zcat $DAT | awk 'BEGIN{FS="\t"; OFS="\t"}{if ($2 > !{lim}) print $3}' | /usr/local/bundle/bin/dirtree -o dirmap3-$U.html
    done < !{ownerlist}
    '''

}


workflow {
//    rawstat = stat_filesystem(params.target_fs)

/*
    rawstat = Channel.fromPath("/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20260713-dev/work/a2/fc982a3ad239be1d20bb8c56b2f79d/rawstat.tsv.gz")
    filelist_A = make_filelist(rawstat, file(params.primary_list), file(params.past_md5_fl))
    dirlist = make_dirlist(rawstat)

    parse_dirs(dirlist, filelist_A)
    make_dirtree(parse_dirs.out.dirmap_all, params.dm3_all_lim)
    make_dirtree_user(parse_dirs.out.dirmap_user.collect(), parse_dirs.out.ownerlist, params.dm3_all_lim)
*/
    filelist_A = Channel.fromPath("/storage1/fs1/m.wyczalkowski/Active/ProjectStorage/Analysis/FSAudit/dinglab.20260713-dev/work/fa/6982e4b7ad93277ae15e7e9dad60cb/filelist.tsv.gz")
    md5 = evaluate_md5_parallel(filelist_A, params.n_parallel_md5)
    update_filelist(md5, filelist_A)
}


