#!/bin/bash -l
#SBATCH --job-name=snp_QC
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cad/ibd_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cad/ibd_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/
source ${script_path}Configs/$1 all
config=$1
outliers=$2
ld_file=${outDir}${outName}.LD_pruned

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)


merge_file=${outDir}${baseName}merge_ibd.txt
> $merge_file

# Exlude high LD regions and subset to number of individuals

for chr in ${chromosomes[@]}
do
	source ${script_path}Configs/$config $chr
	ld_file=${outDir}${outName}.LD_pruned
	echo "----starting "$chr"-----------"
	srun -l plink --bfile $ld_file \
        	--remove $outliers --make-bed \
        	--allow-no-sex --out ${outDir}${outName}.no_close_relatives
	echo ${outDir}${outName}.no_close_relatives >> $merge_file
done

# Merge data together
echo "*************************************MERGE******************************"
srun -l plink --merge-list $merge_file --allow-no-sex \
	--make-bed --out ${outDir}${baseName}chrall.no_close_relatives

