#!/bin/bash -l
#SBATCH --job-name=extract
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/ext_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=3:00:00
#SBATCH --array=0-23

ANNODIR=/nrnb/ukb-majithia/data/OQFE_200k_exm/annotations
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/RV0
outdir=/nrnb/ukb-majithia/epilepsy/outputs/candidates
gene_list=/nrnb/ukb-majithia/sarah/Git/ukbb/epilepsy/gene_lists/gwas_suggested.txt
bim_path=/nrnb/ukb-majithia/data/OQFE_200k_exm
suff=$1

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

anno_file=$ANNODIR/chr${CHR}_cadd_plus_all_annotations.tsv.gz

wc -l $anno_file
#zcat $anno_file | head -n 1

python $script_path/annotation_utility.py $anno_file -f -a Consequence -c \
	-i SPLICE_SITE FRAME_SHIFT STOP_GAINED CANONICAL_SPLICE STOP_LOST \
	-o $outdir/chr${CHR}_deleterious_consequence

#subset to gene list
grep -w -f $gene_list $outdir/chr${CHR}_deleterious_consequence.filtered.tsv > \
	$outdir/chr${CHR}_${suff}_deleterious.tsv

var_count=$(wc -l $outdir/chr${CHR}_${suff}_deleterious.tsv | cut -f1 -d' ')
# check variant IDs in bim file?
if [ $var_count -gt 1 ]
then
	if [ "$CHR" == "Y" ]; then
		sed -i  's/^Y\t/24\t/g' \
			$outdir/chr${CHR}_${suff}_deleterious.tsv
		sed -i  's/\tY:/\t24:/g' \
			$outdir/chr${CHR}_${suff}_deleterious.tsv
	elif [ "$CHR" == "X" ]; then
		sed -i  's/^X\t/23\t/g' \
			$outdir/chr${CHR}_${suff}_deleterious.tsv
		sed -i  's/\tX:/\t23:/g' \
			$outdir/chr${CHR}_${suff}_deleterious.tsv

	fi
	awk -v out=$outdir/chr${CHR}_varlist.temp '(NR >1){print $5 > out}' \
		$outdir/chr${CHR}_${suff}_deleterious.tsv
	awk '{print $0 "\t" $1 ":" $4 ":" $6 ":" $5 "\t" $1 ":" $4 ":" $5 ":" $6}' \
		$bim_path/UKBexomeOQFE_chr$CHR.bim | \
	grep -f $outdir/chr${CHR}_varlist.temp > \
		$outdir/chr${CHR}_deleterious.bim

	awk '(NR>1){print $5 "\t" $7}' $outdir/chr${CHR}_${suff}_deleterious.tsv |
		sort -k 1 > $outdir/chr${CHR}_gene.sorted
	sort -k 7 $outdir/chr${CHR}_deleterious.bim | \
		join -1 1 -2 7 $outdir/chr${CHR}_gene.sorted - | \
		awk -v out=$outdir/chr${CHR}_gene.match \
			'{print $4 "\t" $2 > out}'
# extract variants from  plink

else
	echo "No variants in chromosome: "$CHR
fi
