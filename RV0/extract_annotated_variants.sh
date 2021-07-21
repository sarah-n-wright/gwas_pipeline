
ANNODIR=/nrnb/ukb-majithia/data/OQFE_200k_exm/annotations
script_dir=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/RV0
outdir=/nrnb/ukb-majithia/?????

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
CHR=${chromosomes[$SLURM_ARRAY_TASK_IS]}

anno_file=$ANNODIR/chr${CHR}_cadd_plus_all_annotations.tsv.gz

python $script_path/filter_annotations.py $anno_file -a Consequence -c \
	-i SPLICE_SITE FRAME_SHIFT STOP_GAINED CANONICAL_SPLICE STOP_LOST \
	-o $outdir/chr${CHR}_deleterious_consequence

