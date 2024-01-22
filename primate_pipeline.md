#primate pipeline

#PAF to MAF
wgatools filter -f paf -a 10000000 chm13.paf -o chm13.filter_10Mb.paf -r -t32
wgatools trimovp chm13.notrans.paf > chm13.notrans.noovp.paf
wgatools pp chm13.notrans.noovp.paf -o parallel_outdir -r -f primates16.20231205.fa.gz -t8


#chop alignment
#note:need to change the names to match the tree
mkdir CHUNKS
/rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/msa_split chm13#1#chr19#filtered#edited.maf --in-format MAF --refseq chm13#1#chr19.fa --windows 1000000,0 --out-root CHUNKS/chm13#1#chr19 --out-format SS --min-informative 1000 --between-blocks 5000

#fit initial model
/rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phyloFit --tree primate_tree.nwk --msa-format MAF --out-root init chm13#1#chr19#filtered#edited.maf

#estimate trees
mkdir -p TREES log     # put estimated tree models here
rm -f TREES/*      # in case old versions left over
for file in CHUNKS/*.*.ss ; do 
	root=`basename $file .ss` 
		sbatch -pvgl -c4 --output=log/slurm-%j.out --wrap="time /rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phastCons --gc 0.4766 --estimate-trees TREES/$root $file init.mod --no-post-probs"
done

#combine models
ls TREES/*.cons.mod > cons.txt
ls TREES/*.noncons.mod > noncons.txt
/rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phyloBoot --read-mods '*cons.txt' --output-average ave.cons.mod
/rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phyloBoot --read-mods '*noncons.txt' --output-average ave.noncons.mod 
 
#generate scores
mkdir -p ELEMENTS SCORES log/elements_scores
rm -f ELEMENTS/* SCORES/*
for file in CHUNKS/*.*.ss ; do 
    root=`basename $file .ss` 
    sbatch -pvgl -c4 --output=log/elements_scores/slurm-%j.out --wrap="time /rugpfs/fs0/vgl/store/gformenti/bin/PHAST/phast/bin/phastCons --most-conserved ELEMENTS/$root.bed --score $file ave.cons.mod,ave.noncons.mod > SCORES/$root.wig"
done