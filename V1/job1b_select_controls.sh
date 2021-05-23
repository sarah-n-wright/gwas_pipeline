#!/bin/bash -l
#SBATCH --job-name=controls
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cont_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cont_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=8:00:00
#SBATCH --array=0
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
config=$1
file_suff=$2
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
source ${script_path}select_controls.sh $config 1 $file_suff

for CHR in "${chromosomes[@]}"; do
	source ${script_path}Configs/$config $CHR
	srun -l plink --bfile ${outDir}${outName}.${file_suff} \
		--keep ${outDir}${baseName}.case_control.keep --make-bed \
		--allow-no-sex --out ${outDir}${outName}.CC
done

