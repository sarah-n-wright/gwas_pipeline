#!/bin/bash -l
#SBATCH --job-name=clump
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cad/clump_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cad/clump_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/

source ${script_path}Configs/$1 all
test=log.assoc.logistic
pval=0.00001

srun -l plink --bfile ${outDir}${outName}.QCed \
	--clump ${outDir}${outName}.$test \
	--clump-p1 $pval \
	--out ${outDir}${outName}

echo "-------------------- Clumping performed-------------------------"

cyto=/nrnb/ukb-majithia/data/reference/cytoBand_hg38.txt

outfile=${outDir}${outName}.clump_loci

awk '{if (NR>1) {print $0}}' ${outDir}${outName}.clumped | \
        sort -k 1 - | \
        awk '{if ((NR>1) && (NF>2)) {print "chr"$1 "\t" $4 "\t" $4 + 1}}' | \
        sort -k 1 - > ${outDir}${outName}.hits.temp


cat $cyto | bedops -e 1 - ${outDir}${outName}.hits.temp > $outfile

awk '{print $1 $4}' $outfile | sed 's/chr//g' | sed 's/\s//g' > $outfile.loci

echo "--------------------Generated loci information----------------------------"
