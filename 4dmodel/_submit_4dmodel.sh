#!/bin/bash

rm -rf matrix3D.txt combinations.txt LOGS ELEMENTS SCORES
mkdir -p ELEMENTS SCORES LOGS

lens=($(seq 0 50 30000))
tcs=($(seq 0 0.05 1))

for len in "${lens[@]}" 
do 
    for tc in "${tcs[@]}"
    do
        printf "${len} ${tc}\n" >> combinations.txt
    done 
done

if [ ! -f 4d.mod ]; then

    grep '^chr21' chm13v2.0_RefSeq_Liftoff_v5.1.gff3 | grep 'exon' | sed 's/chr21/Homo_sapiens/g' > chm13.chr21.exon.gff
    sort -k1,1 -k4,4n chm13.chr21.exon.gff | bedtools merge > chm13.chr21.exon.bed
    msa_view chm13#1#chr21.filtered.edited.maf --in-format MAF --4d --features chm13.chr21.exon.gff > 4d-codons.ss
    msa_view 4d-codons.ss --in-format SS --out-format SS --tuple-size 1 > 4d-sites.ss
    phyloFit --tree primate_tree.nwk --msa-format SS --out-root 4d 4d-sites.ss

fi

printf "\
sbatch --nice=10000 --partition=vgl,vgl_bigmem,hpc --array=1-$(wc -l < combinations.txt)%%128 --cpus-per-task=1 --output=LOGS/slurm-%A_%a.log enrichment_3dspace.sh\n"
sbatch --nice=10000 --partition=vgl,vgl_bigmem,hpc --array=1-$(wc -l < combinations.txt)%128 --cpus-per-task=1 --output=LOGS/slurm-%A_%a.log enrichment_3dspace.sh | awk '{print $4}' > job.jid

WAIT="afterok:"
jid=`cat job.jid`
WAIT=$WAIT$jid

sbatch --partition=vgl,vgl_bigmem,hpc --dependency=$WAIT enrichment_combine.sh
