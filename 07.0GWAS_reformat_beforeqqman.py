import subprocess
import os

subprocess.run(["pip", "install", "qqman"])
# qqman in /home/jupyter/.local/lib/python3.10/site-packages

subprocess.run(["pip", "install", "numpy"])
# numpy in /opt/conda/lib/python3.10/site-packages

subprocess.run(["pip", "install", "pandas"])
# pandas in /opt/conda/lib/python3.10/site-packages 

subprocess.run(["pip", "install", "matplotlib"])
# matplotlib in /opt/conda/lib/python3.10/site-packages

# reformatting 

import pandas as pd
import subprocess
from io import StringIO

# command that is grabbing the top 5  
data_tsv = "gsutil cat gs://fc-secure-bb61452f-d5e2-4d26-9227-6a9444241af8/data/META_formatted_filtered_714.1.tsv"

# run os command, avoid any errors to keep it clean so theyre piped 
command = subprocess.run(data_tsv, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# make the data from the file human readable
data = command.stdout.decode('utf-8')

# because original tsv is sep by \t, read the data as such 
df = pd.read_csv(StringIO(data), sep='\t')
# string IO so that we can manipulate the data as a dataframe 

# for the locus, pos, chr, and pvalue data... rename the columns we are interested in for qqman 
df['SNP'] = df['SNP']  # SNP is already correct
df['CHR'] = df['CHR'].astype(str)  # Ensure it's string
df['BP'] = df['POS']
df['P'] = df['Pvalue']

# keeping only the required columns wanted by qqman
result = df[['SNP', 'CHR', 'BP', 'P']]

# saving the results to a txt with space separation for usability in qqman, will not accept tsv or csv...
output_file = '~/GWAS-TWAS-in-All-of-Us-Cloud/reformat_output_file.txt'
result.to_csv(output_file, index=False, sep = ' ')

#just to verify that the file was made 
print(f"{output_file} made")
