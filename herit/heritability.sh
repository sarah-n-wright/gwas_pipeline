#!/bin/bash -l
#SBATCH --job-name=herit
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/herit_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/herit_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=64G
#SBATCH --time=12:00:00

source ../Configs/$1 21
suff=$2
plink=~/.conda/envs/Command/bin/plink
pcgc=/nrnb/ukb-majithia/sarah/Git/S-PCGC
ref=$pcgc/1000G_hg38
out=${outDir}herit
mkdir $out

awk -v outfile=${outDir}chr21.phe '{print $1 "\t" $1 "\t" $6 > outfile}' \
	${outDir}${outName}.updated_phe.fam

if [ 1 -eq 1 ]
then

# create sync file
srun -l python $pcgc/pcgc_sync.py \
	--annot-chr $ref/baselineLD_v2.2/baselineLD. \
	--frqfile-chr $ref/plink_files/1000G.EUR.hg38. \
	--out $ref/baselineLD_v2.2/baselineLD

# create whatever this step is
for i in {1..22};
do
	srun -l python $pcgc/pcgc_r2.py \
	--annot $ref/baselineLD_v2.2/baselineLD.${i}. \
	--sync $ref/baselineLD_v2.2/baselineLD. \
	--bfile $ref/plink_files/1000G.EUR.hg38.${i} \
	--extract $out/good_snps.${i}.txt \
	--out $ref/baselineLD_v2.2/baselineLD.goodsnps.$suff.${i}
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
	--annot $ref/baselineLD_v2.2/baselineLD.${i}. \
	--pheno ${outDir}chr21.phe \
	--frqfile $ref/plink_files/1000G.EUR.hg38.${i}. \
	--sync $ref/baselineLD_v2.2/baselineLD. \
	--prev 0.01 \
	--out $out/sumstats/ss_${suff}_chr_${i}
done

fi
if [ 1 -eq 1 ]
then
srun -l python $pcgc/pcgc_main.py \
	--annot-chr $ref/baselineLD_v2.2/baselineLD. \
	--sync $ref/baselineLD_v2.2/baselineLD. \
	--sumstats-chr $out/sumstats/ss_${suff}_chr_ \
	--prodr2-chr $ref/baselineLD_v2.2/baselineLD.goodsnps.$suff. \
	--out $out/sumstats/pcgc.$suff
fi
