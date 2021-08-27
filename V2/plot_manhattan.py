import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

from qqman import qqman

filename = str(sys.argv[1])
out_pref = str(sys.argv[2])
chr_col=str(sys.argv[3])
snp_col=str(sys.argv[4])
bp_col=str(sys.argv[5])
p_col=str(sys.argv[6])


qqman.manhattan(filename,out=out_pref+"_Manhattan.png", col_chr=chr_col, col_snp=snp_col, col_bp=bp_col, col_p=p_col)
