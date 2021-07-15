## Adapted from github.com/MareesAT/GWA_tutorial/1_QC_GWAS/gender_check.R
import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

import pandas as pd
import matplotlib.pyplot as plt

file_pref = str(sys.argv[1])
out_pref = "/cellar/users/snwright/Data/Transfer/gwas_qc_plots/" + str(sys.argv[2])
gender = pd.read_csv(file_pref+".sexcheck", sep="\s+")
data_col = gender.columns[5]
plt.figure()
plt.hist(gender.loc[(gender["PEDSEX"]==1), data_col], bins=100, label="male", alpha=0.6)
plt.hist(gender.loc[(gender["PEDSEX"]==2), data_col], bins=100, label="female", alpha=0.6)
plt.xlabel("F-score")
plt.ylabel("Number of individuals")
plt.title("Sex Score")
plt.savefig(out_pref+"sexcheck.png")
