source ${script_path}Configs/$1 $2

ibd_file=${outDir}${outName}.IBD.genome
# make u/v
u_out=${outDir}${outName}.U.temp
v_out=${outDir}${outName}.V.temp

awk -v out=$u_out '{print $1 "\t" $2 "\t" $10 > out}' $ibd_file
awk -v out=$v_out '(NR > 1) {print $3 "\t" $4 "\t" $10 > out}' $ibd_file
cat $v_out >> $u_out
cat $u_out | datamash --headers --group 1,2 mean 3 > ${outDir}${outName}.IBD_INDIV.txt

mean=$(cat ${outDir}${outName}.IBD_INDIV.txt | datamash -H mean 3 | awk '(NR>1) {print $1}')
sd=$(cat ${outDir}${outName}.IBD_INDIV.txt | datamash -H sstdev 3 | awk '(NR>1) {print $1}')
thresh=$(echo "scale = 2; ${mean} + ${ibd_sigma}*${sd}" | bc)

awk -v th=$thresh -v out=${outDir}${outName}.IBD_INDIV_outliers.remove \
	'BEGIN{print "FID" "\t" "IID" "\t" "mean_PI_HAT"} (NR>1) {if ($3 >= th) {print $0 > out}}' \
	${outDir}${outName}.IBD_INDIV.txt


srun -l plink --bfile ${outDir}${outName}.no_close_relatives \
	--remove ${outDir}${outName}.IBD_INDIV_outliers.remove --make-bed \
	--out ${outDir}${outName}.IBD_cleaned

