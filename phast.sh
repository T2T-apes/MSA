#!/bin/bash
mkdir -p MAF ELEMENTS SCORES LOOKUP
# extract only relevant alignments 
head -1 ../../MAF_10Mb_new/$1 > MAF/${1%.*}#filtered.maf
grep -f <(awk -F',' '{print $1}' lookup.csv) ../../MAF_10Mb_new/$1 >> MAF/${1%.*}#filtered.maf

# extract names of the alignments in the MAF
grep -f <(awk -F',' '{print $1}' lookup.csv) MAF/${1%.*}#filtered.maf | awk '{print $2}' | awk -F',|#' 'NR==FNR{name[$1]=$3; next} {print $0","name[$1]}' lookup.csv - > LOOKUP/$2.csv

# fix species names in the MAF
python3 list_replace.py MAF/${1%.*}#filtered.maf LOOKUP/$2.csv > MAF/${1%.*}#filtered#edited.maf

# run phastcons
/rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phastCons \
	--most-conserved ELEMENTS/$2.bed --score MAF/${1%.*}#filtered#edited.maf --msa-format MAF ave.cons.mod,ave.noncons.mod > SCORES/$2.wig

# edit ids
sed -i 's/#filtered#edited//g' SCORES/$2.wig
sed -i 's/#filtered#edited//g' ELEMENTS/$2.bed

# convert to bigWig
wigToBigWig SCORES/$2.wig chrom.sizes SCORES/$2.bigWig
