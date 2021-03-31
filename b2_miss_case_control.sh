source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

in_file=${outDir}${outName}.filtered_for_missingess

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

