#!/bin/bash -l
#SBATCH --job-name=plot
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/plot_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/plot_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/

source ${script_path}Configs/$1 all

srun -l python ${script_path}plotman.py ${outDir}${outName}. log.assoc.logistic ${outName}.assoc_log
srun -l python ${script_path}plotQQ.py ${outDir}${outName}. log.assoc.logistic ${outName}.assoc_log
srun -l python ${script_path}plotman.py ${outDir}${outName}. assoc ${outName}.assoc
srun -l python ${script_path}plotQQ.py ${outDir}${outName}. assoc ${outName}.assoc
