#!/bin/bash -l
#SBATCH --job-name=sex_check
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/sx1_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/sx1_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --parsable
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
override_thresholds=$2 #1=yes 0=no
minF=$3 # only specify if override_thresholds=1
maxF=$4 # only specify if override_thresholds=1

source ${script_path}Configs/$config "X"

echo ${SLURM_JOB_ID}" : job2_sex_check.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job2_sex_check.sh : "$(date) >> \
	${outDir}${baseName}.track

no_split=$(echo ${sex_chr[@]} | grep -c "XY")
file_name=${outDir}${outName}.updated_phe

echo $override
echo $minF
echo $maxF

echo "------------------------------>Performing Sex Check<-------------------------"

if [ $sexInfo -eq 1 ]; then
#source ${script_path}sub_sex_check.sh $config $override_thresholds $minF $maxF
  if [ "$override" -eq 1 ]; then
        echo "OVERRIDING CONFIG THRESHOLDS"
        sexFmin=$minF
        sexFmax=$maxF
        mkdir ${outDir}temp
        mv ${outDir}${baseName}chrX.sex_check* ${outDir}temp/

  else
  # Don't need this if XY region already separated?
    if [ $no_split -eq 0 ]; then
        srun -l plink2 --bfile $file_name \
                --keep ${outDir}${baseName}.pheno.keepID \
                --split-par $build \
                --make-bed --out ${outDir}${outName}.sex_split
        file_name=${outDir}${outName}.sex_split
    fi

# LD prune
    if [ 1 -eq 1 ]; then
  	srun -l plink2 --bfile $file_name \
        	--indep-pairwise $LD_window $LD_shift $LD_r2 \
        	--out ${outDir}${outName}.sex_prune


  	srun -l plink2 --bfile $file_name \
        	--extract ${outDir}${outName}.sex_prune.prune.in \
        	--make-bed --out ${outDir}${outName}.temp
  	echo "--------------------X chromosome pruned-------------------------"
    fi
  fi

  srun -l plink --bfile ${outDir}${outName}.temp \
        --check-sex $sexFmin $sexFmax \
        --allow-extra-chr \
        --out ${outDir}${outName}.sex_check
  echo "--------------------Sex check performed-------------------------"


  srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/plot_gender_check.py ${o$

  echo "--------------------Figure plotted-------------------------"
else
  echo "Sex check turned off by RunConfig.conf"
fi

#rm ${outDir}${baseName}*.log
#rm ${outDir}${baseName}*.nosex
#rm ${outDir}${baseName}*temp*
#rm ${outDir}${baseName}*.sex_split.*
#rm ${outDir}${baseName}*.sex_prune.*
