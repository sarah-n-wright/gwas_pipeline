source /cellar/users/snwright/Git/examples/GWAS/RunConfig.conf

# iteratively filter for missingness

aspercent=$aspercent=$(echo $missStart " / 100" | bc -l)
genomind_1=$(echo "1-"$aspercent | bc -l)

srun -l plink --bfile ${outDir}${outName}.common --geno $genomind_1 --make-bed \
--out ${outDir}${outName}.common_snp${missStart}

srun -l plink --bfile ${outDir}${outName}.common_snp${missStart} --mind $genomind_1 \
--make-bed --out ${outDir}${outName}.common_sample$missStart.snp$missStart

echo "------------------------------>completed initial filter<-----------------------"

newstep=$(($missStart+$missStep))

for i in $(seq $newstep $missStep $missEnd)

do

aspercent=$(echo $i " / 100" | bc -l)
genomind=$(echo "1-"$aspercent | bc -l)
prefix=$(($i-$missStep))

srun -l plink --bfile ${outDir}${outName}.common_sample$prefix.snp$prefix \
--geno $genomind --make-bed --out ${outDir}${outName}.common_sample$prefix.snp$i

srun -l plink --bfile ${outDir}${outName}.common_sample$prefix.snp$i \
--mind $genomind --make-bed --out ${outDir}${outName}.common_sample$i.snp$i

echo "------------------------------>completed "${i}"% filter<-----------------------"

done

srun -l plink --bfile ${outDir}${outName}.common_sample$missEnd.snp$missEnd \
--make-bed --out ${outDir}${outName}.filtered_for_missingness

echo "------------------------------>completed all filters<-----------------------"

