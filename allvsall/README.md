# primate pipeline all vs all

Briefly, the pipeline is as follow:
1. Given each PAF to reference alignment (`batch.sh`)
2. Generate MAF files for each chromosome (`maf_to_paf.sh`)
3. Process each MAF for PHAST including splitting it into smaller chunks (`process_maf.sh`)
4. Process each CHUNK in parallel (`process_chunk.sh`)
5. Combine all SCORES and ELEMENT predictions (`combine_results.sh`)
