source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

# iteratively filter for missingness
if [ $sexInfo -eq 1 ]
then
	in_bed=${outDir}${outName}.sexcheck_cleaned.bed
	in_bim=${outDir}${outName}.sexcheck_cleaned.bim
	in_fam=${outDir}${outName}.sexcheck_cleaned.fam
else
	in_bed=$bedfile
	in_bim=$bimfile
	in_fam=$fam_file
fi

## produce the missingness statistics
srun -l plink --bed $in_bed --bim $in_bim --fam $in_fam --missing \
--out ${outDir}${outName}

## Plot histograms of the missingess.
srun -l python /cellar/users/snwright/Git/gwas_pipeline/hist_miss.py ${outDir}${outName} $outName


aspercent=$aspercent=$(echo $missStart " / 100" | bc -l)
genomind_1=$(echo "1-"$aspercent | bc -l)

srun -l plink --bed $in_bed --bim $in_bim --fam $in_fam --geno $genomind_1 --make-bed \
--out ${outDir}${outName}.snp_${missStart}

srun -l plink --bfile ${outDir}${outName}.snp_${missStart} --mind $genomind_1 \
--make-bed --out ${outDir}${outName}.samp_$missStart.snp_$missStart

echo "------------------------------>completed initial filter<-----------------------"

newstep=$(($missStart+$missStep))

for i in $(seq $newstep $missStep $missEnd)

do

aspercent=$(echo $i " / 100" | bc -l)
genomind=$(echo "1-"$aspercent | bc -l)
prefix=$(($i-$missStep))

srun -l plink --bfile ${outDir}${outName}.samp_$prefix.snp_$prefix \
--geno $genomind --make-bed --out ${outDir}${outName}.samp_$prefix.snp_$i

srun -l plink --bfile ${outDir}${outName}.samp_$prefix.snp_$i \
--mind $genomind --make-bed --out ${outDir}${outName}.samp_$i.snp_$i

echo "------------------------------>completed "${i}"% filter<-----------------------"

done

srun -l plink --bfile ${outDir}${outName}.samp_$missEnd.snp_$missEnd \
--make-bed --out ${outDir}${outName}.filtered_for_missingness

mkdir ${outDir}temp/
mv ${outDir}${outName}.samp_* ${outDir}temp/
mv ${outDir}${outName}.snp_* ${outDir}temp/

echo "------------------------------>completed all filters<-----------------------"

