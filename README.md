# GWAS-TWAS-in-All-of-Us-Cloud

# hacking instructions: 
1. clone repo
2. you will be using test data "cleaned_TESTDATA_hacking.txt" and scripts "qqman_reformatting.py" and "qqman_hacking.r"
3. run qqman_reformatting.py with # python qqman_reformatting.py --input cleaned_TESTDATA_hacking.txt --output reformat_output_file.txt
4. then, run "qqman_hacking.r", it will use the result from the first script.
5. the result from the R script will be a pdf. Open it in vscode or in the browser. vscode will need a module download, browser cant be edge. 
