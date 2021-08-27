import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

from qqman import qqman
import pandas as pd

filename = str(sys.argv[1])
out_pref = str(sys.argv[2])
chr_col=str(sys.argv[3])
snp_col=str(sys.argv[4])
bp_col=str(sys.argv[5])
p_col=str(sys.argv[6])

assoc = pd.read_csv(filename,usecols=[chr_col, bp_col, p_col], sep="\s+", index_col=False)
assoc.columns=["CHR", "BP", "P"]

qqman.qqplot(assoc,out=out_pref+"_QQ.png", col_p="P")

