#!/bin/bash -l
#SBATCH --job-name=exome_QC
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/test/f1_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/test/f1_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
CHR=""
config=$1

source ${script_path}single/e1_LD_prune.sh $config "" exclude.reduced

#echo "############################ Prune 1 COMPLETED ##########################"

#for chr in ${chromosomes[@]}
#do
source ${script_path}f1_ibd.sh $config "" $out
source ${script_path}f2_indiv_ibd.sh $config "" $out
#done
#echo "############################ Prune 2 COMPLETED ##########################"

#source ${script_path}f1_relatedness.sh $config $CHR $out

#echo "############################ Prune 3 COMPLETED ##########################"

source ${script_path}g1_pca.sh $config $CHR $out

# echo "############################ Prune 4 COMPLETED ##########################"

