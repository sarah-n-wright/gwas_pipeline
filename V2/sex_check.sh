source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/Configs/$1 "X"

override=$2
minF=$3
maxF=$4
no_split=$(echo ${sex_chr[@]} | grep -c "XY") 
file_name=${outDir}${outName}.updated_phe

echo $override
echo $minF
echo $maxF

if [ "$override" -eq 1 ]
then
	echo "OVERRIDING CONFIG THRESHOLDS"
	sexFmin=$minF
	sexFmax=$maxF
	mkdir ${outDir}temp
	mv ${outDir}${baseName}chrX.sex_check* ${outDir}temp/
else

  # Don't need this if XY region already separated?
  if [ $no_split -eq 0 ]
  then
	srun -l plink2 --bfile $file_name \
		--keep ${outDir}${baseName}.pheno.keepID \
		--split-par $build \
		--make-bed --out ${outDir}${outName}.sex_split
	file_name=${outDir}${outName}.sex_split
  fi

# LD prune
  if [ 1 -eq 1 ]
  then
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


srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/gender_check.py ${outDir}${outName}.sex_check ${outName}

echo "--------------------Figure plotted-------------------------"


grep "PROBLEM" ${outDir}${outName}.sex_check.sexcheck | \
awk '{print $1 "\t" $2}' > ${outDir}${outName}.sex_check.removeID

echo "--------------------Discord file created-------------------------"

grep -vwF -f ${outDir}${outName}.sex_check.removeID \
	${outDir}${baseName}.pheno.keepID | \
	grep -vwF -f ${outDir}${outName}.updated_phe.nosex > \
	${outDir}${baseName}.sex.keepID

