#!/bin/bash -l
#SBATCH --job-name=assoc_prep
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=64G
#SBATCH --time=2:00:00
config=$1
assocMethod=$2 # BOLT
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
source ${script_path}Configs/$config 1

## covariates ---------------------------------------------------------------------
covariates=/nrnb/ukb-majithia/epilepsy/phenotypes/cov_sorted.tsv
pcs=${outDir}${baseName}.eigenvec

sed 's/\s/\t/g' $pcs | sort -k 1 -o ${outDir}${baseName}combined.pca.pcs.sorted

join -1 1 -2 1 $covariates ${outDir}${baseName}combined.pca.pcs.sorted | \
	sed 's/\s/\t/g' | \
	cut -f1,2,3,4,6- > ${outDir}${baseName}combined.all_covariates.tsv
sed -ie "1i\FID\tIID\tSEX\tYOB\tPC1\tPC2\tPC3\tPC4\tPC5\tPC6\tPC7\tPC8\tPC9\tPC10" \
	${outDir}${baseName}combined.all_covariates.tsv

## remove samples ------------------------------------------------------------------
awk -v out=${outDir}${baseName}.temp.keepID '(NR>1){print $1 > out}' \
	${outDir}${baseName}.king.keepID
grep -vw -f ${outDir}${baseName}.temp.keepID $famfile \
	> ${outDir}${baseName}.final.removeID
rm ${outDir}${baseName}.temp.keepID

## include variants ----------------------------------------------------------------
for chr in ${chromosomes[@]}
do
	source ${script_path}Configs/$config $chr
	grep -vw -f ${outDir}${outName}.extractVAR $bimfile \
		> ${outDir}${outName}.temp.excludeVAR
done
cat ${outDir}${baseName}chr*.temp.excludeVAR > ${outDir}${baseName}.final.excludeVAR

## pheno file ---------------------------------------------------------------------
srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
	--remove ${outDir}${baseName}.final.removeID \
	--make-pheno $case_list '*' \
	--make-just-fam --out ${outDir}${baseName}.final.phe

sed -ie "1i\FID IID F M SEX PHENO" ${outDir}${baseName}.final.phe.fam

## BOLT Specific files -------------------------------------------------------------
if [ "$assocMethod" == "BOLT" ]
then
	echo "BOLT"
## SAIGE Specific files ------------------------------------------------------------
elif [ "$assocMethod" == "SAIGE" ]
then
	# TODO - saige specific .sample file for bgen.
	# combined phenotype/covar file
	awk '(NR>1){print $1 "\t" $6}' ${outDir}${baseName}.final.phe.fam | \
		sort -k 1 | sed -E 's/1$/0/g' | sed -E 's/2$/1/g' | \
		sed -e '1i\FID PHENO' | \
		join -1 1 -2 1 --header \
		- ${outDir}${baseName}combined.all_covariates.tsv > \
		${outDir}${baseName}.final.phe.cov
	# combine pheno and covar
	echo "SAIGE"
else
	echo "PLINK"
fi
echo "Merging files------------------------------------"
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
merge=${outDir}${baseName}final_merge.txt
> $merge
for chr in ${chromosomes[@]}
do
	# get the temporary filtered dataset
	srun -l plink --bfile ${outDir}${baseName}chr${chr}.updated_phe \
		--remove ${outDir}${baseName}.final.removeID \
		--exclude ${outDir}${baseName}chr${chr}.temp.excludeVAR \
		--make-bed --out ${outDir}${baseName}chr${chr}.final.temp
		echo ${outDir}${baseName}chr${chr}.final.temp >> $merge
	if [ 1 -eq 0 ]
	then
		# create VCF file from plink set
		srun -l plink2 --bfile ${outDir}${baseName}chr${chr}.final.temp \
			--fa /nrnb/ukb-majithia/data/reference/GRCh37/hs37d5.fa \
			--ref-from-fa \
			--recode vcf id-paste=iid \
			--out ${outDir}${baseName}chr${chr}.final

		# Compress and index the vcf file
		bgzip ${outDir}${baseName}chr$chr.final.vcf
		tabix -p vcf -C ${outDir}${baseName}chr$chr.final.vcf.gz
	fi
	if [ 1 -eq 1 ]
	then
		# create BGEN file from plink set
		srun -l plink2 --bfile ${outDir}${baseName}chr${chr}.final.temp \
			--fa /nrnb/ukb-majithia/data/reference/GRCh37/hs37d5.fa \
			--ref-from-fa \
			--export bgen-1.2 id-paste=iid bits=8 \
			--out ${outDir}${baseName}chr${chr}.final

		# Index the bgen file
		bgenix -g ${outDir}${baseName}chr$chr.final.bgen -index
		# create the single column sample file for SAIGE
		grep -Ev "^0 |^ID" ${outDir}${baseName}chr$chr.final.sample | \
			awk -v out=${outDir}${baseName}chr$chr.saige.sample \
			'{print $1 > out}'
	fi
done
#srun -l plink --merge-list $merge --allow-no-sex \
#		--make-bed --out ${outDir}${baseName}combined.final

rm ${outDir}${baseName}*final.temp*
rm ${outDir}${baseName}chr*.temp.excludeVAR


echo "---------------------------DONE---------------------------"

