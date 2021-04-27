source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2

in_file=${outDir}${outName}.filtered_for_missingess

srun -l plink --bfile $in_file --test-missing --out ${outDir}${outName}_test_cc

mkdir ${outDir}final_stats/
mv ${outDir}${outName}_test_cc.missing ${outDir}final_stats/
