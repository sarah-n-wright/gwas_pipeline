source ${script_path}Configs/$1 $2
suff=$3

srun -l plink2 --bfile ${outDir}${outName}.${suff} --pca approx \
	--out ${outDir}${outName}.pca2

srun -l python plot_pca.py ${outDir}${outName}.pca2 ${outName}
