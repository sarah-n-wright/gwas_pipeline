source ${script_path}Configs/$1 $2

# iteratively filter for missingness
if [ $sexInfo -eq 1 ]
then
	in_bed=${outDir}${outName}.sexcheck_cleaned.bed
	in_bim=${outDir}${outName}.sexcheck_cleaned.bim
	in_fam=${outDir}${outName}.sexcheck_cleaned.fam
else
	in_bed=${outDir}${outName}.updated_phe.bed
	in_bim=${outDir}${outName}.updated_phe.bim
	in_fam=${outDir}${outName}.updated_phe.fam
fi

## produce the missingness statistics
srun -l plink --bed $in_bed --bim $in_bim --fam $in_fam --missing \
--out ${outDir}${outName}

## Plot histograms of the missingess.
srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/hist_miss.py ${outDir}${outName} $outName


aspercent=$(echo $missStart " / 100" | bc -l)
genomind_1=$(echo "1-"$aspercent | bc -l)

srun -l plink --bed $in_bed --bim $in_bim --fam $in_fam --geno $genomind_1 --make-bed \
--out ${outDir}${outName}.snp_${missStart}

wc -l ${outDir}${outName}.snp_$missStart.bim >> ${outDir}${outName}.missingness_steps.tsv

srun -l plink --bfile ${outDir}${outName}.snp_${missStart} --mind $genomind_1 \
--make-bed --out ${outDir}${outName}.samp_$missStart.snp_$missStart

wc -l ${outDir}${outName}.samp_$missStart.snp_$missStart.fam >> ${outDir}${outName}.missingness_steps.tsv

echo "------------------------------>completed initial filter<-----------------------"

newstep=$(($missStart+$missStep))

for i in $(seq $newstep $missStep $missEnd)

do

aspercent=$(echo $i " / 100" | bc -l)
genomind=$(echo "1-"$aspercent | bc -l)
prefix=$(($i-$missStep))

srun -l plink --bfile ${outDir}${outName}.samp_$prefix.snp_$prefix \
--geno $genomind --make-bed --out ${outDir}${outName}.samp_$prefix.snp_$i

wc -l ${outDir}${outName}.samp_$prefix.snp_$i.bim >> ${outDir}${outName}.missingness_steps.tsv

srun -l plink --bfile ${outDir}${outName}.samp_$prefix.snp_$i \
--mind $genomind --make-bed --out ${outDir}${outName}.samp_$i.snp_$i

wc -l ${outDir}${outName}.samp_$i.snp_$i.fam >> ${outDir}${outName}.missingness_steps.tsv

echo "------------------------------>completed "${i}"% filter<-----------------------"

done

srun -l plink --bfile ${outDir}${outName}.samp_$missEnd.snp_$missEnd \
--make-bed --out ${outDir}${outName}.filtered_for_missingness

mkdir ${outDir}temp/
mv ${outDir}${outName}.samp_* ${outDir}temp/
mv ${outDir}${outName}.snp_* ${outDir}temp/

echo "------------------------------>completed all filters<-----------------------"

