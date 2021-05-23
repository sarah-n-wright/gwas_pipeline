#!/bin/bash -l
#SBATCH --job-name=herit
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cov_herit_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cov_herit_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=8:00:00

source ../Configs/$1 21

plink=~/.conda/envs/Command/bin/plink
pcgc=/nrnb/ukb-majithia/sarah/Git/S-PCGC
ref=$pcgc/1000G_hg38
out=${outDir}herit
cov_file=/nrnb/ukb-majithia/epilepsy/phenotypes/cov_sorted.tsv
mkdir $out
if [ 1 -eq 1 ]
then

# create sync file
srun -l python $pcgc/pcgc_sync.py \
	--frqfile-chr $ref/plink_files/1000G.EUR.hg38. \
	--out $ref/baselineLD_v2.2/baselineLD.noAnno

# create whatever this step is
for i in {1..22};
do
	srun -l python $pcgc/pcgc_r2.py \
	--sync $ref/baselineLD_v2.2/baselineLD.noAnno. \
	--bfile $ref/plink_files/1000G.EUR.hg38.${i} \
	--extract $out/good_snps.${i}.txt \
	--out $ref/baselineLD_v2.2/baselineLD.goodsnps.noAnno.${i}
done
fi

if [ 1 -eq 1 ]
then
# get summary statistics
mkdir $out/sumstats
for i in {1..22};
do
	source ../Configs/$1 $i
	srun -l python $pcgc/pcgc_sumstats_creator.py \
	--bfile ${outDir}${outName}.variant \
	--extract $out/good_snps.${i}.txt \
	--covar $cov_file \
	--pheno ${outDir}chr21.phe \
	--frqfile $ref/plink_files/1000G.EUR.hg38.${i}. \
	--sync $ref/baselineLD_v2.2/baselineLD.noAnno. \
	--prev 0.01 \
	--out $out/sumstats/ss_chr.noAnno.${i}
done

fi
if [ 1 -eq 1 ]
then
srun -l python $pcgc/pcgc_main.py \
	--sync $ref/baselineLD_v2.2/baselineLD.noAnno. \
	--sumstats-chr $out/sumstats/ss_chr.noAnno. \
	--prodr2-chr $ref/baselineLD_v2.2/baselineLD.goodsnps.noAnno. \
	--out $out/sumstats/pcgc_noAnno
fi
