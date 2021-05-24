## Version 1 - GWAS Pipeline

### Update the Config file
1. Check chromosomes
2. Output directory and name prefix
3. input files
4. case list
5. Run parameters

### Run the jobs in order
`job1a_update_phenotype.sh <config>`  
* `pheno` : `SlurmOut/pheno_%A`   

`job1b_select_controls.sh <config> <input suffix>` E.g. input suffix = updated_phe  
* `controls` : `SlurmOut/cont_%A`  

`job2_sex_check.sh <config> [output suffix]`  
* `sex_check` : `SlurmOut/sx_%A`   

`job3_preLD.sh <config>`  
* `preLD` : `SlurmOut/preLD_%A_%a`  

`job4a_LD_exclude_and_combine.sg <config> [input flag]` Use input flag = 1 to merge   
all reduced files together  
* `LD_excl` : `SlurmOut/ex1_%A`    

`job4b_LD_prune.sh <config> <input suffix>` E.g. input_suffix = exclude.reduced if 
not merged, or LD_in if merged
* `prune` : `SlurmOut/prune_%A_%a`    

`job4c_post_LD_combine.sh <config>`    
* `post_LD` : `SlurmOut/combprune_%A`    

`job5_relate.sh <config>`  
* `relate` : `SlurmOut/relate_A%`    

`job6_prep_assoc.sh <config>`    
* `assoc_prep` : `SlurmOut/assoc_prep_%A`    

`job7_run_assoc.sh <config>`  
* `assoc` : `SlurmOut/assoc_%A`    

`job8a_results_plot.sh <config>`  
* `plot` : `SlurmOut/plot_%A`    

`job8b_results_clump.sh <config>`  
* `clump` : `SlurmOut/clump_%A`   
  
