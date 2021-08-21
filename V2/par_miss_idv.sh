# export outDir baseName
chr=$1

plink2 --bfile ${outDir}${baseName}chr$chr.updated_phe \
        --keep ${outDir}${baseName}.missing.checkID \
        --extract ${outDir}${baseName}chr$chr.filtered_for_missingness.bim \
        --missing sample-only \
        --out ${outDir}${baseName}chr$chr.checkID
