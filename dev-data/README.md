Development of test data for testing purposes.

Initial attempts:
    /home/mwyczalk_test/Projects/DataTracking/FSAudit/FSAudit2025/output/katmai.20251103/dev-data

However, generating test data requires that the dirlist file incorporates paths contained in the filelist.

## Creating test filelist and dirlist files for testing purposes
the approach is to sample some random lines from an existing filelist file and write to a DEV filelist
then, construct a dirlist file based on the files in the DEV filelist

Note that we sort the dirlist after it is created to remove duplicates.  This results in a different order than
what a real dirlist would have.  Assume this is not a problem.


