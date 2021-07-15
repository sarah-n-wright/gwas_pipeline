#!/bin/bash -l
#SBATCH --job-name=plot
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/plot_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
method=$2 # BOLT or SAIGE

source ${script_path}Configs/$config ""

if [ "$method" == "BOLT" ]
then
stats_file=${outDir}final_stats/${baseName}.bolt.stats
srun -l python ${script_path}plotQQ.py $stats_file ${baseName}_bolt CHR SNP BP P_BOLT_LMM
echo "Created QQ plot"
srun -l python ${script_path}plotman.py $stats_file ${baseName}_bolt CHR SNP BP P_BOLT_LMM
echo "Created Manhattan plot"
elif [ "$method" == "SAIGE" ]
then
stats_file=${outDir}final_stats/${baseName}combined.BGEN.stats
srun -l python ${script_path}plotQQ.py $stats_file ${baseName}_saige CHR rsid POS p.value
echo "Created QQ plot"
srun -l python ${script_path}plotman.py $stats_file ${baseName}_saige CHR rsid POS p.value
echo "Created Manhattan plot"
fi

echo "-----------------------DONE------------------"
