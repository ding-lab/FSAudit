# Given input data from 1_, select only the regular files and parse their names and extensions

DAT="dat/Projects.cptac.FS.dat"
OUT="dat/files.FS.dat"

if [[ ! -e $DAT ]]; then
>&2 echo Error: $DAT does not exist
exit 1
fi



## file_name	file_type	total_size	owner_name	time_mod	hard_links
#./GDC_import/import.config/CPTAC3.b4.b/CPTAC3.b4.SR.dat	regular file	67842	mwyczalk_test	2018-05-06 17:22:24.510740693 -0500	1

python parse_fs.py < $DAT > $OUT

echo Written to $OUT

