#!/bin/bash -l
#SBATCH --job-name=extract
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/ext_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=3:00:00

outdir=/nrnb/ukb-majithia/epilepsy/outputs/candidates
ukbb_path=/nrnb/ukb-majithia/data/OQFE_200k_exm
suff=$1

cat $outdir/chr*_deleterious.bim > $outdir/chrall_deleterious.bim
awk '{print $2 > "chrall_deleterious.extractVAR"}' $outdir/chrall_deleterious.bim

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')

for CHR in ${chromosomes[@]}
do
	if grep -wq "^"$CHR $outdir/chrall_deleterious.bim; then
	plink --bed $ukbb_path/ukb23155_c${CHR}_b0_v1.bed \
		--bim $ukbb_path/UKBexomeOQFE_chr${CHR}.bim \
		--fam $ukbb_path/ukb23155_c22_b0_v1.fam \
		--extract $outdir/chrall_deleterious.bim \
		--make-pheno $outdir/../../inputs/epilepsy_6441.cases.phe '*' \
		--freq 'case-control' \
		--out $outdir/chr${CHR}_deleterious

	sed '/CHR/d' $outdir/chr${CHR}_deleterious.frq.cc | \
		sort -k 2 | \
		join -1 2 -2 1 - $outdir/chr${CHR}_gene.match | \
		sed 's/\s/\t/g' > $outdir/chr${CHR}_deleterious.frq.cc.anno
	fi
done

cat $outdir/chr*_deleterious.frq.cc.anno > $outdir/chrall_deleterious.frq.cc.anno

sed '/CHR/d' $outdir/chrall_deleterious.frq.cc.anno | sort -k 9 | \
	datamash -W -g 9 --narm mean 5 mean 6 > $outdir/epi_deleterious_MAF_$suff.tsv

#sed -i '1i\SNP\tCHR\tA1\tA2\tMAF_A\tMAF_U\tNCHROBS_A\tNCHROBS_U\tGENE' \
#	$outdir/chrall_deleterious.frq.cc.anno
