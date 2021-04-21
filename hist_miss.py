## Adapted from github.com/MareesAT/GWA_tutorial/1_QC_GWAS/hist_miss.R
import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

import pandas as pd
import matplotlib.pyplot as plt

file_pref = str(sys.argv[1])
out_pref = "/cellar/users/snwright/Data/Transfer/" + str(sys.argv[2])
indmiss = pd.read_csv(file_pref+".imiss", sep="\s+")
snpmiss = pd.read_csv(file_pref+".lmiss", sep="\s+")

plt.figure()
plt.hist(indmiss.iloc[:, 5], bins=100)
plt.xlabel("Percent missinginess")
plt.ylabel("Number of individuals")
plt.title("Individual Missingess")
plt.savefig(out_pref+"Figure_imiss.png")

plt.figure()
plt.hist(snpmiss.iloc[:, 4], bins=100)
plt.xlabel("Percent missingess")
plt.ylabel("Number of variants")
plt.title("Variant Missingness")
plt.savefig(out_pref+"Figure_lmiss.png")

