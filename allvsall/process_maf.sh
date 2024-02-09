#!/bin/bash
set -e -o pipefail

paf_name=$1

maf_file=$(sed -n "${SLURM_ARRAY_TASK_ID}p" MAF/${paf_name}/file.ls)

maf_name="$(basename -- $maf_file)"
maf_name=${maf_name%.maf}

if [ ! -f MAF_FILTERED/${paf_name}/${maf_name}.filtered.edited.maf ]; then

    ## compute MAF coverage
    if [ ! -f ${maf_file%.*}.cov ]; then
        /usr/bin/time -vv /rugpfs/fs0/vgl/store/gformenti/bin/maf_stream/target/release/maf_stream coverage ${maf_name%.*} $maf_file ${maf_file%.*}.cov &> /dev/null
    fi

    ## extract interesting alignments
    head -1 $maf_file > ${maf_file%.*}.filtered.maf
    grep -f <(awk -F',' '{print $1}' LOOKUPS/${paf_name}.csv) $maf_file >> ${maf_file%.*}.filtered.maf

    ## match tree names and maf names
    grep -f <(awk -F',' '{print $1}' LOOKUPS/${paf_name}.csv) ${maf_file%.*}.filtered.maf | awk '{print $2}' | awk -F',|#' 'NR==FNR{name[$1]=$3; next} {print $0","name[$1]}' LOOKUPS/${paf_name}.csv - > LOOKUPS/$maf_name.csv
    python3 list_replace.py ${maf_file%.*}.filtered.maf LOOKUPS/$maf_name.csv > MAF_FILTERED/${paf_name}/${maf_name}.filtered.edited.maf
    
    rm ${maf_file%.*}.filtered.maf

fi

## chop alignments
if [ ! -d CHUNKS/${maf_name} ]; then
    gfastats FASTA/${paf_name}.fa $maf_name -o FASTA/${maf_name}.fa
    mkdir -p CHUNKS/${maf_name}
    /rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/msa_split MAF_FILTERED/${paf_name}/${maf_name}.filtered.edited.maf --in-format MAF --refseq FASTA/${maf_name}.fa --windows 1000000,0 --out-root CHUNKS/${maf_name}/${maf_name} --out-format SS --min-informative 1000 --between-blocks 5000
fi

## generate scores
mkdir -p ELEMENTS/${maf_name} SCORES/${maf_name}
rm -f ELEMENTS/${maf_name}/* SCORES/${maf_name}/*

ls CHUNKS/${maf_name}/${maf_name}*.*.ss > CHUNKS/${maf_name}/file.ls
NFILES=$(cat CHUNKS/${maf_name}/file.ls | wc -l)	

sbatch  --nice=10000 --array=1-${NFILES} -c1 -pvgl --output=LOG/process_chunk-%j.out process_chunk.sh ${maf_name} | awk '{print $4}' > CHUNKS/${maf_name}/jid

sbatch  --nice=10000 --dependency=afterok:`cat CHUNKS/${maf_name}/jid` -pvgl -c1 --output=LOG/combine_results-%j.out combine_results.sh ${maf_name}