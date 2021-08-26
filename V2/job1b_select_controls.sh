#!/bin/bash -l
#SBATCH --job-name=controls
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cont_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cont_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --parsable
#SBATCH --time=0:30:00

## TODO - check that ID file is correct with all controls (might have 3 cols)

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
file_suff=updated_phe
#control_per=$2 # set to 0 to keep all controls (e.g. 200 = 200%)
#icd10_file=/nrnb/ukb-majithia/epilepsy/inputs/any_icd10_sorted.txt
#exclude_patt=$3 #regex of values to exclude, "" for no exclusion
hesin_file=/nrnb/ukb-majithia/20201215_hesin_diag.txt

source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job1b_select_controls.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job1b_select_controls.sh : "$(date) >> \
	${outDir}${baseName}.track

# create the controls.keepID file
# source ${script_path}sub_select_controls.sh $CONFIG 1 $FILE_SUFF $CONTROL_PER $ICD10_FILE $EXCLUDE_PATT

# Get number of cases
n_cases=$(awk '{if ($6==2) {s++}}END{print s}' ${outDir}${outName}1.$file_suff.fam)

# Initialize file
> ${outDir}${baseName}.pheno.keepID

if [ "$n_cases" > 0 ]; then
# -----------------------------
# Exclude any controls with no ICD10 codes
  if [ "$icd10_file" = "" ]; then
        awk -v outfile=${outDir}${baseName}.controls.phe '{ if ($6==1) {print $1 > outfile}}' ${outDir}${outName}1.$file_suff.fam 
  else
        awk -v outfile=${outDir}${baseName}.controls_temp.phe '{ if ($6==1) {print $1 > outfile}}' ${outDir}${outName}1.$file_suff.fam
	sort -k 1 ${outDir}${baseName}.controls_temp.phe | \
                join -1 1 -2 1 \
                $icd10_file - \
                > ${outDir}${baseName}.controls.phe
        rm ${outDir}${baseName}.controls_temp.phe
  fi
# Exclude comorbidities
  if [ "$exclude_patt" != "" ]; then
        grep -Ev $exclude_patt $hesin_file | \
        awk '(NR>1){ a[$1]++ } END { for (b in a) { print b } }' | \
        sort | join -1 1 -2 1 ${outDir}${baseName}.controls.phe - > \
		${outDir}${baseName}.controls_temp.phe
	echo "Controls remaining:"
        wc -l ${outDir}${baseName}.controls_temp.phe
        mv ${outDir}${baseName}.controls_temp.phe ${outDir}${baseName}.controls.phe
  fi
# subset to number of controls desired
  if [ $control_per != 0 ]; then
        n_controls=$(expr $n_cases \* $control_per / 100)
        echo $n_cases
        echo $n_controls
        shuf ${outDir}${baseName}.controls.phe -n $n_controls | sort | \
        awk -v out=${outDir}${baseName}.pheno.keepID '{print $1 "\t" $1 > out}'
        rm ${outDir}${baseName}.controls.phe
  else
	awk -v out=${outDir}${baseName}.pheno.keepID '{print $0 "\t" $1 > out}' \
        ${outDir}${baseName}.controls.phe
        rm ${outDir}${baseName}.controls.phe
  fi
        echo "Adding cases"
        cat $case_list >> ${outDir}${baseName}.pheno.keepID
else
        awk -v out=${outDir}${baseName}.pheno.keepID \
        '{print $1 "\t" $1 > out}' ${outDir}${baseName}.$file_suff.fam
# -------------------------------------------

fi

