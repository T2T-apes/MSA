#!/bin/bash
set -e -o pipefail

## Dependencies: gfastats, PHAST, samtools

REFERENCE_GENOMES="primates16.20231205.clean.fa"
ALN_FOLDER="primates16.20231205_wfmash-v0.12.5"

mkdir -p MAF FILTERED_MAF FILTERED_PAF FASTA CHUNKS ELEMENTS SCORES LOOKUPS LOG

if [ ! -f ${REFERENCE_GENOMES}.fai ]; then
    samtools faidx $REFERENCE_GENOMES
fi

for paf_file in ${ALN_FOLDER}/*.aln.paf
do
    paf_name="$(basename -- $paf_file)"
    paf_name=${paf_name%.aln*}
    mkdir -p LOG/$paf_name
    sbatch --nice=10000 -pvgl -c32 --output=LOG/${paf_name}/paf_to_maf-%j.out paf_to_maf.sh $paf_file $REFERENCE_GENOMES
done
