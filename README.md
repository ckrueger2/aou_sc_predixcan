# GWAS-TWAS-in-All-of-Us-Cloud

## hacking instructions: 
Clone this repository
### qqman
1. you will be using test data "cleaned_TESTDATA_hacking.txt" and scripts "qqman_reformatting.py" and "qqman_hacking.r"
2. run qqman_reformatting.py with: 
``` python qqman_reformatting.py --input cleaned_TESTDATA_hacking.txt --output reformat_output_file.txt ```
4. then, run "qqman_hacking.r", it will use the result from the first script.
5. the result from the R script will be a pdf. Open it in vscode or in a browser. VScode will require a module download to handle pdfs, and i have noticed that the browser cant be microsoft edge. 

### Locuszoomr
Utilizing the **cleaned_TESTDATA_hacking.txt** test data, run the script below to visualize the most significant SNP:
```bash
Rscript locuszoomrHacking.R
```

### S-PrediXcan
#### Install miniconda
run these lines from the terminal to install miniconda3
```
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
```
next, run these lines from the terminal to activate conda
```
source ~/miniconda3/bin/activate
conda init --all
source ~/.bashrc
```
#### Set Up MetaXcan
run
```
./set-up-metaxcan.sh
```
to install MetaXcan, set up conda venv, and download reference files for S-PrediXcan
#### Run S-PrediXcan
first, set up the virtual environment created by the last script using
```
conda activate imlabtools
```
then run the following script to run S-PrediXcan on the test data
```
python run-predixcan.py -i cleaned_TESTDATA_hacking.txt -o predixcan-results/hack-test.csv
```
the results will be contained in `predixcan-results/hack-test.csv`

# TUTORIAL ON GWAS SAMPLE DATA DOWNLOAD 

## 1. GWAS CATALOG
   go to the following website: https://www.ebi.ac.uk/gwas/
   once you are in the home, go to download 
   once in downloads, go to summary statistics 

## 2. FTP site data download
   you will now be on the FTP site with all user available summary statisitcs 
   If you scroll, there will be a table describing the data, the author, pubmed ID, accession number, date, table, etc. 
   in the final column, "data access", there will be a hyperlink for FTP download. 

## 3. FTP download
   to download the data, use wget
   
```
    wget https://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST008001-GCST009000/GCST008440/Offenbacher-26962152_pct3.txt
```
## 4. making test data a good size 
edit the table by removing low pvalues 

run this code 
```
import pandas as pd

input_file = ##'TESTDATA_hacking_COVID-19_Patients.tsv'  # the file you got from ebi YOU WILL HAVE TO EDIT THIS 
output_file = 'GWAS-TWAS-in-All-of-Us-Cloud/cleaned_TESTDATA_hacking.txt'  # what the new data will be called (this is the file in the github )

#read the tsv and sep by \t since tsv
df = pd.read_csv(input_file, sep='\t')

#filter based on pvalue 
df_filtered = df[df['Pvalue'] < 0.05]

#save the data as \t so the code still works 
df_filtered.to_csv(output_file, sep='\t', index=False)
```

#then youre done! you should have significant pvalue SNPs that can be used for testing code 
