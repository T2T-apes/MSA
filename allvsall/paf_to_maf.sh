#!/bin/bash
set -e -o pipefail

paf_file=$1
REFERENCE_GENOMES=$2
mkdir -p LOG/$1

declare -A genomes=(\
[Gorilla_gorilla]="na" \
[Pan_paniscus]="na" \
[Pan_troglodytes]="na" \
[Pongo_abelii]="na" \
[Pongo_pygmaeus]="na" \
[Symphalangus_syndactylus]="na" \
[Homo_sapiens]="na" \
)

paf_name="$(basename -- $paf_file)"
paf_name=${paf_name%.aln*}

## populate lookup table
genomes[$(grep ${paf_name} genomes_lookup.csv | cut -d, -f2)]=${paf_name}
for i in "${!genomes[@]}"
do
    if [ ${genomes[${i}]} == "na" ]; then
        genomes[$i]=$(grep -m 1 ${i} <(shuf genomes_lookup.csv) | cut -d, -f1)
    fi
done
rm -f LOOKUPS/${paf_name}.csv
for i in "${!genomes[@]}"; do echo "${genomes[$i]},${i}"; echo "${genomes[$i]},${i}" >> LOOKUPS/${paf_name}.csv; done

## PAF to MAF
if [ ! -d MAF/${paf_name} ]; then
    /usr/bin/time -vv /rugpfs/fs0/vgl/store/gformenti/bin/wgatools/target/release/wgatools filter -f paf -a 10000000 ${paf_file} -o FILTERED_PAF/${paf_name}.aln.filtered.paf -r -t32
    /usr/bin/time -vv /rugpfs/fs0/vgl/store/gformenti/bin/wgatools/target/release/wgatools pp FILTERED_PAF/${paf_name}.aln.filtered.paf -o MAF/${paf_name} -r -f ${REFERENCE_GENOMES} -t32
fi

## extract fasta reference
if [ ! -f FASTA/${paf_name}.fa ]; then
    echo "extracting: ${paf_name}"
    grep ${paf_name} ${REFERENCE_GENOMES}.fai | cut -f1 > FASTA/${paf_name}.ls
    gfastats -i FASTA/${paf_name}.ls ${REFERENCE_GENOMES} -o FASTA/${paf_name}.fa
fi

mkdir -p MAF_FILTERED/${paf_name}/

grep -vf <(ls SCORES/${paf_name}*bigWig | sed -e 's/SCORES\/\|\.bigWig//g') <(ls MAF/${paf_name}/*.maf) > MAF/${paf_name}/file.ls

NFILES=$(cat MAF/${paf_name}/file.ls | wc -l)

sbatch --nice=10000 --array=1-${NFILES}%16 -c1 -pvgl --output=LOG/${paf_name}/process_maf-%A_%a.out process_maf.sh ${paf_name}