#!/bin/bash

genome=$1

rm -f COMBINED/ELEMENTS/$genome.bed COMBINED/SCORES/$genome.wig COMBINED/SCORES/$genome.bw COMBINED/MAF/$genome.maf

while read chr
do
    
    if [ -f ELEMENTS/$chr.bed ]; then
        cat ELEMENTS/$chr.bed >> COMBINED/ELEMENTS/$genome.bed
    fi
      
    if [ -f SCORES/$chr.wig ]; then
        cat SCORES/$chr.wig >> COMBINED/SCORES/$genome.wig
    fi
    
    if [ -f MAF/*/$chr.maf ]; then
        cat MAF/*/$chr.maf >> COMBINED/MAF/$genome.maf
    fi

done< <(grep $genome primates16.20231205.clean.fa.fai | awk '{print $1}')

wigToBigWig COMBINED/SCORES/$genome.wig chrom.sizes COMBINED/SCORES/$genome.bw
#    mafToBigMaf $genome COMBINED/MAF/$genome.maf COMBINED/MAF/$genome.bmaf 