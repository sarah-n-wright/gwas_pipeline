## Step 1 ## Update phenotype & select controls##
config=$1

source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 ""

sbatch update_phenotype_job.sh $config

if [ $case_list == "" ]
then
	echo "no cases"
else
	sbatch select_controls_job.sh $config updated_phe
fi
## Step 2 ## Sex Combine ##
# Do on just the case control data??
if [ $sexInfo -eq 1 ]
then
	sbatch combine_sex_job.sh $config ""
fi
#TODO get list of discordant

## Step 3 ## Pipe steps a-d
	#Sex check
	#Missingness
	#Missingnes CC
	#HWE
	#MAF filter

sbatch run_pipe_v1.sh $config

## LD Exlcusion ##

sbatch LD_exclude_and_combine.sh $config

## LD-pruning & relatedness ##

#sbatch run_prune_QC_v1.sh $config
