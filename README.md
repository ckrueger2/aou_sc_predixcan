# GWAS-TWAS-in-All-of-Us-Cloud

## hacking instructions: 
1. clone repo
2. you will be using test data "cleaned_TESTDATA_hacking.txt" and scripts "qqman_reformatting.py" and "qqman_hacking.r"
3. run qqman_reformatting.py with # python qqman_reformatting.py --input cleaned_TESTDATA_hacking.txt --output reformat_output_file.txt
4. then, run "qqman_hacking.r", it will use the result from the first script.
5. the result from the R script will be a pdf. Open it in vscode or in the browser. vscode will need a module download, browser cant be edge. 

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
edit the table by removing low pvalues :) 

run this code 
```
import pandas as pd

input_file = 'TESTDATA_hacking_COVID-19_Patients.tsv'  # the file you got from ebi 
output_file = '/home/2025/acarcione/cleaned_TESTDATA_hacking.txt'  # what the new data will be called (this is the file in the github )

#read the tsv and sep by \t since tsv
df = pd.read_csv(input_file, sep='\t')

#filter based on pvalue 
df_filtered = df[df['Pvalue'] < 0.05]

#save the data as \t so the code still works 
df_filtered.to_csv(output_file, sep='\t', index=False)
```

#then youre done! you should have significant pvalue SNPs that can be used for testing code :) 
