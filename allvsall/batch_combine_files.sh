#!/bin/bash

awk '{split($1,h,"#");print h[1]}' primates16.20231205.clean.fa.fai | sort | uniq > genomes.ls

mkdir -p COMBINED/ELEMENTS COMBINED/SCORES COMBINED/MAF

awk '{printf $1"\t"$2"\n"}' primates16.20231205.clean.fa.fai > chrom.sizes

while read genome
do 

sbatch -pvgl -c16 combine_files.sh $genome

done<genomes.ls
