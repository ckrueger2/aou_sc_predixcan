# Project 5: GWAS, TWAS, and Data Viz in the All of Us Cloud (Ben, Claudia, Angelina, Drew)
***
## Using All of Us Cloud Environment
### Get Approved
In order to access sensitive All of Us GWAS data, you must create and account, verify your identity, and complete the requisite training. The steps to do this can be found in the wiki at [Registering for All of Us](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/wiki/1.-Registering-for-All-of-Us).

### Navigating and Creating a Workspace
The next step is to create a workspace at your Research Workbench. The [Using All of Us Website and Cloud](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/wiki/2.-Using-All-of-Us-Website-and-Cloud) page on the wiki will walk you through the website. 
Your workspace will house any GWAS data you pull along with all scripts from this repository and their output.
***
## Using the Pipeline
### Clone Repo
To access these scripts, clone this repository in your workspace. Information on how to do this and how to run scripts from this repo in your workspace is in [Using This Repository](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/wiki/3.-Using-This-Repository).

### Analysis
Once these scripts are in your workspace, you will be able to run them to pull and analyze All of Us GWAS data. This can be done with the wrapper to run all analyses at once, or each tool can be run individually. Each tool is detailed in its respective wiki page; the wrapper is detailed below.

### 00Wrapper
Prior to running the 00wrapper.sh script, run `chmod +x ~/GWAS-TWAS-in-All-of-Us-Cloud/00wrapper.sh`

Running the 00Wrapper.sh will execute scripts 1 through 4, which include pulling GWAS summary statistics, formatting them, plotting a Manhattan plot, and running LocusZoom on one locus of interest.

To run the wrapper use the following command within the All of Us terminal under the Hail Table Environment: `bash ~/GWAS-TWAS-in-All-of-Us-Cloud/00wrapper.sh --phecode <PHECODE> --pop <POP> --rsid <RSID> --token <TOKEN>`

- Phecode and Population arguments are required - See Wiki 4. Retrieving Summary Statistics for phecode and population options
- rsid and token arguments are optional
> To view a locus with locuszoomr other than the locus with the lowest P-value SNP, specify the rsID of a SNP within the locus of interest. This SNP will also serve as the reference SNP for linkage disequilibrium disply

> Token represents the LDlink personal access code needed to display linkage disequilibrium when plotting with locuszoomr. To make a one-time request for your personal access token follow the directions within the following web browser at https://ldlink.nih.gov/?tab=apiaccess.

### 00twas-wrapper
Prior to running the 00wrapper.sh script, run `chmod +x ~/GWAS-TWAS-in-All-of-Us-Cloud/00twas-wrapper.sh`

Then, set clone the tool into your repo and set up a conda environment for S-PrediXcan via `bash ~/GWAS-TWAS-in-All-of-Us-Cloud/set-up-predixcan.sh`

This second wrapper performs the TWAS part of this tool. It executes scripts 5 & 6, which imputes TWAS summary statistics and generates a Manhattan plot of those data.

Run the wrapper via `bash ~/GWAS-TWAS-in-All-of-Us-Cloud/00twas-wrapper.sh --phecode <PHECODE> --pop <POP> --ref <REF>`

`<PHECODE>` is the phenotype code of interest
`<POP>` is the population the same originates from
`<REF>` is the reference database to use
Possible reference databases can be displayed by including the `--databases` flag
***
## Pipeline Outline: 
### The [wrapper](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/00wrapper.sh) will run the following scripts:
### 1. [Pulling Data](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/01pull_data.py)
- retrieves hail tables of GWAS summary statistics from the AoU cloud based on a user-defined ancestral population abbreviation and phecode that corresponds to a phenotype of interest
### 2. [Table Formatting](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/02table_format.R)
- accommodates various input formatting requirements by subsequent tools
### 3. [GWAS qqman](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/03gwas_qqman.R)
- visualizes GWAS summary statistics results via Manhattan Plot
### 4. [locuszoomR](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/04locuszoom.R)
-  visualize all of the SNPs in a specific locus
### 5. [S-PrediXcan Wrapper](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/05predixcan-wrapper.ipynb)
- imputes TWAS summary statistics from GWAS summary statistics
### 6. [TWAS qqman (and biomaRt)](https://github.com/bmoginot/GWAS-TWAS-in-All-of-Us-Cloud/blob/main/06twas_qqman.R)
- visualizes TWAS summary statistics results via Manhattan Plot

