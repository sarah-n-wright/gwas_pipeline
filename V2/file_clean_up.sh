config=$1
stage=$2 #postqc or postassoc

source Configs/$config
pref=${outDir}${baseName}

if [ "$stage" == "postqc" ]; then
  keep=${outDir}${baseName}KEEP
  mkdir $keep
  mv ${pref}chr*png $keep
  mv ${pref}.*png $keep
  mv ${pref}.pca* $keep
  rm ${pref}chr*LD_in*
  rm ${pref}chr*highLD*
  mv ${pref}chr*extractVAR $keep
## For bolt
  mv ${pref}chr*.excludeVAR $keep
  mv ${pref}chr*.final.bim $keep
  mv ${pref}chr*.final.fam $keep
  mv ${pref}chr*.final.bed $keep
  mv ${pref}.final.removeID $keep
  mv ${pref}.final.phe.fam $keep
  mv ${pref}combined.all_covariates.tsv $keep
## For SAIGE
  mv ${pref}combined.LD_pruned.*m $keep
  mv ${pref}combined.final.*m $keep
  mv ${pref}combined.LD_pruned.bed $keep
  mv ${pref}combined.final.bed $keep
  mv ${pref}.imp.phe.cov $keep
  mv ${pref}.final.phe.cov $keep
  mv ${pref}chr*.final.bgen $keep
  mv ${pref}chr*.final.bgen.bgi $keep
  mv ${pref}chr*.saige.sample $keep
## Remove files
  rm ${pref}.*eigen*
  rm ${pref}chr*checkID*
  rm ${pref}combined*king*
  rm ${pref}.*king*
  rm ${pref}chr*.log
  rm ${pref}.*.log
  rm ${pref}chr*.nosex
  rm ${pref}.*.nosex
  rm ${pref}.*.keepID
  rm ${pref}combined*kin0*
  rm ${pref}chr*updated_phe*
  rm ${pref}chr*LD_pruned*
  rm ${pref}chr*imiss
  rm ${pref}chr*lmiss
  rm ${pref}chr*missingness*
  rm ${pref}chr*prune.*
  rm ${pref}chr*final.sample
  rm ${pref}chr*temp*
  rm ${pref}chr*sex*
  rm ${pref}.sex*
  rm ${pref}merge*
  rm ${pref}.miss.removeID

  mv $keep/* $keep/..
  rm ${outDir}temp/${baseName}chr*
  rmdir $keep
elif [ "$stage" == "postassoc" ]; then
  keep=${outDir}${baseName}KEEP
else
  echo "Invalid stage supplied."
fi
