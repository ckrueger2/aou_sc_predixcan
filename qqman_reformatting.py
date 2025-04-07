import sys
import argparse

#function to parse command line arguments
def check_arg(args=None):
    parser = argparse.ArgumentParser(description="ADD TITLE OF SCRIPT HERE (shows on help)")
    parser.add_argument("-i", "--input",
    help="input file",
    required=True)
    parser.add_argument("-o", "--output",
    help="output file",
    required=True)
    return parser.parse_args(args)

#retrieve command line arguments
arguments = check_arg(sys.argv[1:])
infile = arguments.input
outfile = arguments.output

##############################
# python /home/2025/acarcione/qqman_reformatting.py --input /home/2025/acarcione/cleaned_TESTDATA_hacking.txt --output reformat_output_file.txt

##############################

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

# read in files so that they can be reformmatted for qqman (in progress) 
# SNP_ID = locus
# BP_location = pos
# P = pvalue 
# CHR = CHR but remove "chr"

# #format: 

#   SNP CHR BP         P
# 1 rs1   1  1 0.9148060
# 2 rs2   1  2 0.9370754
# 3 rs3   1  3 0.2861395
# 4 rs4   1  4 0.8304476
# 5 rs5   1  5 0.6417455
# 6 rs6   1  6 0.5190959


# # looking at the data in the tsv file so i can understand how to change it up 
# top_ten = "gsutil cat gs://fc-secure-bb61452f-d5e2-4d26-9227-6a9444241af8/data/filtered_261.2.tsv | head -n 10"
# with os.popen(top_ten) as file:
#     print(file.read())


with open(infile) as f: #here i am opening the infile
    data_tsv = f.read()
    #print(data_tsv)


# reformatting 

import pandas as pd
import subprocess
from io import StringIO

# # command that is grabbing the top 5  
# data_tsv = "gsutil cat gs://fc-secure-bb61452f-d5e2-4d26-9227-6a9444241af8/data/filtered_261.2.tsv"

# run os command, avoid any errors to keep it clean so theyre piped 
# result = subprocess.run(data_tsv, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

df = pd.read_csv(infile, sep='\t')



# this part needed for all of us cloud but not for python script with test data...
# make the data from the file human readable
# data = result.stdout.decode('utf-8')

# because original tsv is sep by \t, read the data as such 
# df = pd.read_csv(StringIO(data), sep='\t')
# string IO so that we can manipulate the data as a dataframe 

# for the locus, pos, chr, and pvalue data... rename the columns we are interested in for qqman 
df['SNP'] = df['locus']
df['BP'] = df['POS']
df['CHR'] = df['CHR'].astype(str).str.replace('chr', '') #remove the chr part cause we dont want that
df['P'] = df['Pvalue']

# keeping only the required columns wanted by qqman
result = df[['SNP', 'CHR', 'BP', 'P']]

# saving the results to a txt with space separation for usability in qqman, will not accept tsv or csv...
# output_file = '/home/jupyter/GWAS-TWAS-in-All-of-Us-Cloud/reformat_output_file.txt'
result.to_csv(outfile, index=False, sep = ' ')

#just to verify that the file was made 
print(f"{outfile} made")