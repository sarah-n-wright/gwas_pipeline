#!/bin/bash -l
#SBATCH --job-name=preLD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/idv_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/idv_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=4:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
#chromosomes=(21)
config=$1
out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

source ${script_path}Configs/$config ""

cat ${outDir}temp/${baseName}*mindrem.id | grep -v "IID" | sort | \
	uniq > ${outDir}${baseName}.missing.checkID

for chr in ${chromosomes[@]}
do
srun -l plink2 --bfile ${outDir}${baseName}chr$chr.updated_phe \
	--keep ${outDir}${baseName}.missing.checkID \
	--extract ${outDir}${baseName}chr$chr.filtered_for_missingness.bim \
	--missing sample-only \
	--out ${outDir}${baseName}chr$chr.checkID
done

cat ${outDir}${baseName}*.checkID.smiss | grep -v "IID" | \
	sort -k 1 > ${outDir}${baseName}.checkID.temp

cat ${outDir}${baseName}.checkID.temp | \
	datamash -W --narm -g 1 mean 6 max 6 > ${outDir}${baseName}.checkID.means

mean_th=$(echo $(expr 100 - $missEnd) " / 100" | bc -l)
max_th=$(echo $(expr 100 - $missStart) " / 100" | bc -l)

# only remove those with mean greater than top threshold or max greater than
# bottom threshold
awk -v out=${outDir}${baseName}.miss.removeID -v m=$mean_th -v x=$max_th \
'{if ( $2>m || $3>x ) {print $1 "\t" $1 > out}}' ${outDir}${baseName}.checkID.means

grep -vxF -f ${outDir}${baseName}.miss.removeID \
        ${outDir}${baseName}.sex.keepID > ${outDir}${baseName}.miss.keepID


# Get a subset of individuals for LD while we are here.
shuf -n 10000 ${outDir}${baseName}.miss.keepID > ${outDir}${baseName}.LD_subset.keepID

rm ${outDir}${baseName}*filtered_for_missingness*
