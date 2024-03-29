#!/bin/bash

combinations=$(sed -n "${SLURM_ARRAY_TASK_ID}p" combinations.txt)

IFS=" " read len tc <<< $combinations

phastCons --most-conserved ELEMENTS/conserved.$tc.$len.bed --target-coverage $tc --expected-length $len --rho 0.3 --msa-format MAF chm13#1#chr21.filtered.edited.maf 4d.mod > SCORES/scores.$tc.$len.wig

# this is the same as bedtools jaccard:
# intersection=$(bedtools intersect -a chm13.chr21.exon.bed -b <(sed 's/chm13#1#chr21.filtered/Homo_sapiens/g' ELEMENTS/conserved.$tc.$len.bed) | awk '{sum+=$3-$2}END{print sum}')
# union=$(sort -k1,1 -k2,2n <(cat chm13.chr21.exon.bed  <(sed 's/chm13#1#chr21.filtered/Homo_sapiens/g' ELEMENTS/conserved.$tc.$len.bed | awk '{print $1"\t"$2"\t"$3}')) | bedtools merge | awk '{sum+=$3-$2}END{print sum}')
# 
# if [ "$intersection" = "" ] || [ "$intersection" = 0 ]; then
#     intersection=0
#     enrichment=0
# else
#     enrichment=$(echo "scale=5; $intersection / $union" | bc)
# fi

bedtoolsJaccard=$(bedtools jaccard -a chm13.chr21.exon.bed -b <(sed 's/chm13#1#chr21.filtered/Homo_sapiens/g' ELEMENTS/conserved.$tc.$len.bed | awk '{print $1"\t"$2"\t"$3}') | tail -n1)

printf '%s\t' $len $tc ${bedtoolsJaccard[@]} > LOGS/log.$len.$tc.txt
printf '\n' >> LOGS/log.$len.$tc.txt