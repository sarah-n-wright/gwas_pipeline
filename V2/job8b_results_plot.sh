#!/bin/bash -l
#SBATCH --job-name=plot
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/plot_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --parsable
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
method=$2 # BOLT or SAIGE
stats_file_suff=$3 # for final_stats/${baseName}${stats_file_suff}.gz

source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job8b_results_plot.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job8b_results_plot.sh : "$(date) >> \
        ${outDir}${baseName}.track

stats_file=${outDir}final_stats/${baseName}${stats_file_suff}
gunzip $stats_file.gz


if [ "$method" == "BOLT" ]
then
#stats_file=${outDir}final_stats/${baseName}.bolt.stats
srun -l python ${script_path}plot_qq.py $stats_file ${outDir}${baseName}$stats_file_suff CHR SNP BP P_BOLT_LMM_INF
#srun -l python ${script_path}plot_stratifiedQQ.py $stats_file ${baseName}$stats_file_suff.strat CHR SNP BP P_BOLT_LMM_INF A1FREQ
echo "Created QQ plot"
srun -l python ${script_path}plot_manhattan.py $stats_file ${outDir}${baseName}$stats_file_suff CHR SNP BP P_BOLT_LMM_INF
echo "Created Manhattan plot"
convert ${outDir}${baseName}${stats_file_suff}_Manhattan.png \
	${outDir}${baseName}${stats_file_suff}_QQ.png \
	/cellar/users/snwright/Data/Transfer/v3/${baseName}.bolt.assoc.plots.pdf

elif [ "$method" == "SAIGE" ]
then
#stats_file=${outDir}final_stats/${baseName}combined.BGEN.stats
srun -l python ${script_path}plot_qq.py $stats_file ${outDir}${baseName}.saige$stats_file_suff CHR rsid POS p.value
#srun -l python ${script_path}plot_stratifiedQQ.py $stats_file ${baseName}.saige$stats_file_suff.strat CHR SNP BP P_BOLT_LMM_INF AF_Allele2
echo "Created QQ plot"
srun -l python ${script_path}plot_manhattan.py $stats_file ${outDir}${baseName}.saige$stats_file_suff CHR rsid POS p.value
echo "Created Manhattan plot"
convert ${outDir}${baseName}.saige${stats_file_suff}_Manhattan.png \
	${outDir}${baseName}.saige${stats_file_suff}_QQ.png \
	/cellar/users/snwright/Data/Transfer/v3/${baseName}.saige.assoc.plots.pdf
fi

gzip $stats_file

echo "-----------------------DONE------------------"
