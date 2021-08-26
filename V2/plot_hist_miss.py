## Adapted from github.com/MareesAT/GWA_tutorial/1_QC_GWAS/hist_miss.R
import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

import pandas as pd
import matplotlib.pyplot as plt

file_pref = str(sys.argv[1])
out_pref = str(sys.argv[2])
chr = str(sys.argv[3])
indmiss = pd.read_csv(file_pref+".imiss", sep="\s+")
snpmiss = pd.read_csv(file_pref+".lmiss", sep="\s+")

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle("Chromosome: " + chr)
ax1.hist(indmiss.iloc[:, 5], bins=100)
ax1.set_xlabel("Percent missinginess")
ax1.set_ylabel("Number of individuals")
ax1.set_title("Individual Missingess")

ax2.hist(snpmiss.iloc[:, 4], bins=100)
ax2.set_xlabel("Percent missingess")
ax2.set_ylabel("Number of variants")
ax2.set_title("Variant Missingness")
plt.savefig(out_pref+".missingness.png")

