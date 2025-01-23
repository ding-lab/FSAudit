# running FSAudit on compute1



# Old notes for MGI

Goal is to execute FSAudit on all MGI disks using `parallel`
Parallel implementation based on that here: /gscuser/mwyczalk/projects/BICSEQ2/src/process_cases.sh

MGI_dir_list.dat is copy/paste from FSAudit catalog https://docs.google.com/spreadsheets/d/1K3eA3ApWaemksx3oQofgaw9zSZ79qFPeTCm_zrdsE8E/edit#gid=0

bash FSAudit_parallel.sh -J 4 -S MGI_dir_list.dat


## installation

Note that [FSAudit requires the following](https://github.com/ding-lab/FSAudit)

This package requires python 3. R packages which need to be installed: plyr, ggplot2.  Gnu parallel also needs to be installed

On MGI, installing these in conda environment `p3R`.  [Conda cheat sheet](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf)

So when we run this we need to do `conda activate p3R`

Testing on gc3020 looks like it runs to completion

bash 2_process_stats.sh && bash 3_summarize_stats.sh && bash 4_plot_stats.sh

## Fixing runs

Note that the following are still running:
```
-rw-r--r-- 1 mwyczalk ding_mmrf 136314880 Sep 20 11:56 MGI.gc2737.20190918.rawstat.gz
-rw-r--r-- 1 mwyczalk dinglab 129695744 Sep 20 11:56 MGI.gc7210.20190918.rawstat.gz
```


