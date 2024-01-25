#!/bin/bash
while read l; do
  sbatch -pvgl -c4 phast.sh $l
done <$1
