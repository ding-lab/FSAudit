Development of test data for testing purposes.

Initial attempts:
    /home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20251103/dev-data

However, generating test data requires that the dirlist file incorporates paths contained in the filelist.

## Creating test filelist and dirlist files for testing purposes
the approach is to sample some random lines from an existing filelist file and write to a DEV filelist
then, construct a dirlist file based on the files in the DEV filelist

Note that we sort the dirlist after it is created to remove duplicates.  This results in a different order than
what a real dirlist would have.  Assume this is not a problem.

## /home data

We want a mix of files from volumes "/diskmnt" and "/home".  This is done manually for now, combining DEV-100 data
(samples from entire filelist, but which contains no /home data) with manually-generated list of /home data:
    zcat /home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20251103/katmai.20251103.filelist.tsv.gz | grep "^/home" | shuf -n 50 > home-50.filelist.tsv

This becomes DEV-150 dataset
