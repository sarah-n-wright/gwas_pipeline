source ${script_path}Configs/$1 $2

if [ "$case_list" = "" ]
then
        in_file=${outDir}${outName}.filtered_for_missingness
else
        in_file=${outDir}${outName}.CC
fi

# check results of missingnesss?
srun -l plink --bfile $in_file \
--missing --out ${outDir}${outName}.filtered_missing_check

echo "------------------>Check lowest call rates for variants<----------------"
echo "No variants should have more than "${missEnd}"% in column 5"


sort -k 5 -gr ${outDir}${outName}.filtered_missing_check.lmiss | head

echo "------------------>Check lowest call rates for individuals<-------------"
echo "No individuals should have more than "$missEnd"% missing in column 6"

sort -k 6 -gr ${outDir}${outName}.filtered_missing_check.imiss | head

# HWE tests on controls
echo "------------------>Hardy Weinberg Equilibrium<--------------------------"
# Note: default behaviour is to work on controls only when dealing with a case
# control scenario. This is determined by column 6 of the .fam file. 1=control,2=case

srun -l plink --bfile $in_file \
--hardy --out ${outDir}${outName}.hwe_p_values

srun -l plink --bfile $in_file \
--hwe $hwe_pval --make-bed --out ${outDir}${outName}.hwe_dropped

echo "----------------->Finished HWE Equilibrium<-----------------------------"
