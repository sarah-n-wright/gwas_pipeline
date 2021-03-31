import sys
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python37.zip")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/lib-dynload")
sys.path.append("/cellar/users/snwright/.conda/envs/MyPy/lib/python3.7/site-packages")

import pandas as pd

input_file = str(sys.argv[1])
out_name = str(sys.argv[2])

bim = pd.read_csv(input_file, sep='\s+')
bim.columns=["CHR", "Name", "unknown", "POS", "Amin", "Amaj"]
bim["newName"] = bim["CHR"].astype(str) + ":" + bim["POS"].astype(str) + ":" + bim["Amaj"].astype(str) + ":" + bim["Amin"].astype(str)
bim.to_csv(out_name, columns=["newName"], sep="\t", index=False, header=False)

