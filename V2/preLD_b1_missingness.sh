source ${script_path}Configs/$1 $2

# iteratively filter for missingness
in_bed=${outDir}${outName}.updated_phe.bed
in_bim=${outDir}${outName}.updated_phe.bim
in_fam=${outDir}${outName}.updated_phe.fam

## produce the missingness statistics
srun -l plink --bed $in_bed --bim $in_bim --fam $in_fam \
	--keep ${outDir}${baseName}.keepID \
	--missing \
	--out ${outDir}${outName}

## Plot histograms of the missingess.
srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/hist_miss.py ${outDir}${outName} $outName


aspercent=$(echo $missStart " / 100" | bc -l)
genomind_1=$(echo "1-"$aspercent | bc -l)

srun -l plink2 --bed $in_bed --bim $in_bim --fam $in_fam \
	--keep ${outDir}${baseName}.keepID \
	--geno $genomind_1 --make-bed \
	--out ${outDir}${outName}.snp_${missStart}

wc -l ${outDir}${outName}.snp_$missStart.bim >> ${outDir}${outName}.missingness_steps.tsv

srun -l plink2 --bfile ${outDir}${outName}.snp_${missStart} --mind $genomind_1 \
	--make-bed --out ${outDir}${outName}.samp_$missStart.snp_$missStart

wc -l ${outDir}${outName}.samp_$missStart.snp_$missStart.fam >> ${outDir}${outName}.missingness_steps.tsv

echo "------------------------------>completed initial filter<-----------------------"

newstep=$(($missStart+$missStep))

for i in $(seq $newstep $missStep $missEnd)

do

aspercent=$(echo $i " / 100" | bc -l)
genomind=$(echo "1-"$aspercent | bc -l)
prefix=$(($i-$missStep))

srun -l plink2 --bfile ${outDir}${outName}.samp_$prefix.snp_$prefix \
--geno $genomind --make-bed --out ${outDir}${outName}.samp_$prefix.snp_$i

wc -l ${outDir}${outName}.samp_$prefix.snp_$i.bim >> ${outDir}${outName}.missingness_steps.tsv

srun -l plink2 --bfile ${outDir}${outName}.samp_$prefix.snp_$i \
--mind $genomind --make-bed --out ${outDir}${outName}.samp_$i.snp_$i

wc -l ${outDir}${outName}.samp_$i.snp_$i.fam >> ${outDir}${outName}.missingness_steps.tsv

echo "------------------------------>completed "${i}"% filter<-----------------------"

done

srun -l plink2 --bfile ${outDir}${outName}.samp_$missEnd.snp_$missEnd \
--make-bed --out ${outDir}${outName}.filtered_for_missingness

mkdir ${outDir}temp/
mv ${outDir}${outName}.samp_* ${outDir}temp/
mv ${outDir}${outName}.snp_* ${outDir}temp/

echo "------------------------------>completed all filters<-----------------------"

awk -v out=${outDir}${outName}.patt_temp '{print $2 > out}' \
	${outDir}${outName}.filtered_for_missingness.bim

grep -vwF -f ${outDir}${outName}.patt_temp \
        ${outDir}${outName}.updated_phe.bim | \
	awk -v out=${outDir}${outName}.excludeVAR '{print $2 > out}'

rm ${outDir}${outName}.patt_temp
