#!/bin/bash -l
#SBATCH --job-name=assoc_prep
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=100G
#SBATCH --parsable
#SBATCH --time=8:00:00

config=$1
assocMethod=$2 # BOLT
covarOption=$3 # 2=no covar, 0=covar only, 1=covar and all other tasks
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
source ${script_path}Configs/$config 1

echo ${SLURM_JOB_ID}" : job7a_prep_assoc.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job7a_prep_assoc.sh : "$(date) >> \
        ${outDir}${baseName}.track

if [ $covarOption -lt 2 ]; then
## covariates ---------------------------------------------------------------------
  covariates=/nrnb/ukb-majithia/epilepsy/phenotypes/cov_sorted.tsv
  pcs=${outDir}${baseName}.eigenvec

  sed 's/\s/\t/g' $pcs | sort -k 1 -o ${outDir}${baseName}combined.pca.pcs.sorted

  join -1 1 -2 1 $covariates ${outDir}${baseName}combined.pca.pcs.sorted | \
	sed 's/\s/\t/g' | \
	cut -f1,2,3,4,6- | \
	awk -v out=${outDir}${baseName}combined.all_covariates.tsv \
	'{print $0 "\t" 2015 - $4 > out}'
  sed -ie "1i\FID\tIID\tSEX\tYOB\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10\tAge" \
	${outDir}${baseName}combined.all_covariates.tsv
fi

if [ $covarOption -gt 0 ]; then
## remove samples ------------------------------------------------------------------
  grep -w -f /nrnb/ukb-majithia/data/phenotypes/ukb_f22006_white_caucasian_eids.txt \
	${outDir}${baseName}.king.keepID | \
	awk -v out=${outDir}${baseName}.temp.keepID '{print $1 > out}'

  grep -vw -f ${outDir}${baseName}.temp.keepID $famfile \
	> ${outDir}${baseName}.final.removeID
  rm ${outDir}${baseName}.temp.keepID

## pheno file ---------------------------------------------------------------------
  srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
	--remove ${outDir}${baseName}.final.removeID \
	--make-pheno $case_list '*' \
	--make-just-fam --out ${outDir}${baseName}.final.phe

  sed -ie "1i\FID IID F M SEX PHENO" ${outDir}${baseName}.final.phe.fam

# Filter datasets ------------------------------------------------
  merge=${outDir}${baseName}merge_list_final.txt
  > $merge
  chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
  for chr in ${chromosomes[@]}
  do
	echo ${outDir}${baseName}chr${chr}.final >> $merge
  done
## include variants ----------------------------------------------------------------
  for chr in ${chromosomes[@]}
  do
        source ${script_path}Configs/$config $chr
        grep -vw -f ${outDir}${outName}.extractVAR $bimfile \
                > ${outDir}${outName}.temp.excludeVAR
  done
  cat ${outDir}${baseName}chr*.temp.excludeVAR > ${outDir}${baseName}.final.excludeVAR

## Reference genome ---------------------------------------------------------------
  if [ "$build" == 'b37' ]; then
	fasta=/nrnb/ukb-majithia/data/reference/GRCh37/hs37d5.fa
  elif [ "$build" == 'b38' ]; then
	fasta=/nrnb/ukb-majithia/data/reference/GRCh38_full_analysis_set_plus_decoy_hla.fa
  fi

fi
## BOLT Specific files -------------------------------------------------------------
if [ "$assocMethod" == "BOLT" ]; then
	echo "BOLT"
## SAIGE Specific files ------------------------------------------------------------
elif [ "$assocMethod" == "SAIGE" ]; then
	echo "SAIGE"
	# TODO - saige specific .sample file for bgen.
	# combined phenotype/covar file
	if [ $covarOption -lt 2 ]; then
	awk '(NR>1){print $1 "\t" $6}' ${outDir}${baseName}.final.phe.fam | \
		sort -k 1 | sed -E 's/1$/0/g' | sed -E 's/2$/1/g' | \
		sed -e '1i\FID PHENO' | \
		join -1 1 -2 1 --header \
		- ${outDir}${baseName}combined.all_covariates.tsv > \
		${outDir}${baseName}.final.phe.cov
	fi
else
	echo "PLINK"
fi

if [ $covarOption -gt 0 ]; then
	parallel=/cellar/users/snwright/.conda/envs/Command/bin/parallel
	export outDir
	export baseName
	export fasta
	export assocMethod

	$parallel ./par_prep_assoc.sh ::: ${chromosomes[@]}


	srun -l plink --merge-list $merge --allow-no-sex \
		--make-bed --out ${outDir}${baseName}combined.final

	rm ${outDir}${baseName}chr*.temp.excludeVAR

fi
echo "---------------------------DONE---------------------------"

