#!/bin/bash -l
#SBATCH --job-name=report
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/report_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem=10MB
#SBATCH --parsable
#SBATCH --time=1:00:00

##TODO figure out how to get list of job ids as input

config=$1
stage=$2 # for file naming
job_list="$3"
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
source ${script_path}Configs/$config ""

report_file=${outDir}${baseName}.$stage.REPORT
> $report_file

function sacct_report {
  jobid=$1
  sacct -j $jobid -n \
	--format JobID,JobName,State,ExitCode,Elapsed,TotalCPU,Start,End
}

echo $job_list

for job in $job_list
do
  sacct_report $job >> $report_file
done


grep -Eo "^[0-9]+?" $report_file | paste - $report_file > \
	$report_file.temp
mv $report_file.temp $report_file

cat $report_file | datamash -W -g 1,4 countunique 2 > $report_file.summary

echo "Report written to: "$report_file


