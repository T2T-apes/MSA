#!/bin/bash
set -e -o pipefail

## Dependencies: gfastats, PHAST

REFERENCE_GENOMES="../primates16.20231205.fa"
ALN_FOLDER="primates16.20231205_wfmash-v0.12.5"

mkdir -p MAF FILTERED_MAF FILTERED_PAF FASTA CHUNKS ELEMENTS SCORES LOOKUPS LOG

for paf_file in ${ALN_FOLDER}/*.aln.paf
do

    sbatch -pvgl -c32 --output=LOG/paf_to_maf-%j.out paf_to_maf.sh $paf_file $REFERENCE_GENOMES
    exit
done