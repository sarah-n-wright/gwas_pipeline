import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

from qqman import qqman

assoc_type = str(sys.argv[2])
file_pref = str(sys.argv[1])
out_pref = "/cellar/users/snwright/Data/Transfer/" + str(sys.argv[3])
qqman.manhattan(file_pref+assoc_type,out=out_pref+"_Manhattan.png")
