#!/bin/bash
set -e -o pipefail

maf_name=$1

## combine results
cat ELEMENTS/${maf_name}/* > ELEMENTS/${maf_name}.bed
sort -k1,1 -k2,2n ELEMENTS/${maf_name}.bed > ELEMENTS/${maf_name}.sorted.bed
cat $(ls -1 SCORES/${maf_name}/* | awk -F'[.-]' '{print $2"\t"$3"\t"$0}' | sort -nk1 | cut -f3) > SCORES/${maf_name}.wig
rm -r ELEMENTS/${maf_name}.bed ELEMENTS/${maf_name} SCORES/${maf_name}
sed -i 's/#filtered#edited//g' SCORES/${maf_name}.wig
sed -i 's/#filtered#edited//g' ELEMENTS/${maf_name}.sorted.bed
mv ELEMENTS/${maf_name}.sorted.bed ELEMENTS/${maf_name}.bed
gfastats FASTA/${maf_name}.fa -s > FASTA/${maf_name}.chrom.sizes
wigToBigWig SCORES/${maf_name}.wig FASTA/${maf_name}.chrom.sizes SCORES/${maf_name}.bigWig