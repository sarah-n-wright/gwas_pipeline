#!/bin/bash -l
#SBATCH --job-name=good
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/good_snps_%A.log
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=1:00:00
chr=21
source ../Configs/$1 $chr

plink=~/.conda/envs/Command/bin/plink
pcgc=/nrnb/ukb-majithia/sarah/Git/S-PCGC
ref=$pcgc/1000G_hg38
out=${outDir}herit
mkdir $out

for chr in {1..22};
do
source ../Configs/$1 $chr
kG=$ref/plink_files/1000G.EUR.hg38.$chr.bim
ukbb=${outDir}${outName}.variant.bim

sort -k 2 $kG > $ref/plink_files/kG_sort$chr.temp

sort -k 2 $ukbb | join -1 2 -2 2 $ref/plink_files/kG_sort$chr.temp - | \
	awk -v outfile=$out/good_snps.$chr.txt '{print $1 > outfile}'

done

## known clean up;

#sed -i '/rs140661839/d' $out/good_snps.3.txt
#sed -i '/rs186584575/d' $out/good_snps.9.txt
#sed -i '/rs57154009/d' $out/good_snps.16.txt
