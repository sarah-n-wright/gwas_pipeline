import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

import pandas as pd
import matplotlib.pyplot as plt

file_pref = str(sys.argv[1])
out_pref = "/cellar/users/snwright/Data/Transfer/gwas_qc_plots/" + str(sys.argv[2])
pca = pd.read_csv(file_pref + ".eigenvec", sep="\s+")

plt.figure()
plt.scatter(data=pca, x="PC1", y="PC2")
plt.xlabel("PC1")
plt.ylabel("PC2")
plt.savefig(out_pref+"_PCA.png")

