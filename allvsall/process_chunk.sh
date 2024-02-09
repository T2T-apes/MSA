#!/bin/bash
set -e -o pipefail

maf_name=$1

chunk_file=$(sed -n "${SLURM_ARRAY_TASK_ID}p" CHUNKS/${maf_name}/file.ls)
root=`basename $chunk_file .ss`
echo "\
/usr/bin/time /rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phastCons --most-conserved ELEMENTS/${maf_name}/$root.bed --score $chunk_file ave.cons.mod,ave.noncons.mod > SCORES/${maf_name}/$root.wig"
/usr/bin/time /rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phastCons --most-conserved ELEMENTS/${maf_name}/$root.bed --score $chunk_file ave.cons.mod,ave.noncons.mod > SCORES/${maf_name}/$root.wig