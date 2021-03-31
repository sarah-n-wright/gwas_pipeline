#!/bin/bash -l
#SBATCH --job-name=test
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/redo_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/redo_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=8:00:00
#SBATCH --array=0-25

echo "redo_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out"
