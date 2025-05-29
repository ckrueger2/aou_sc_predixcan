# All of Us + TopMed MESA S-PrediXcan and Colocalization analysis
***
### 00Wrapper
Prior to running the 00wrapper.sh script, run
```
chmod +x ~/aou_predixcan/00wrapper.sh
```

Upload a list of SNPs to be used in colocalization analysis: `gsutil -m cp -v unique_mesa_snps.txt.gz {PASTE_YOUR_BUCKET_HERE}/data/` {see below for bucket retrieval details}

Running the 00Wrapper.sh will execute scripts 1 through 4, which include pulling GWAS summary statistics, formatting them, plotting a Manhattan plot, and running LocusZoom on one locus of interest.

To run the wrapper use the following command within the All of Us terminal under the Hail Table Environment:
```
bash ~/aou_predixcan/00wrapper.sh --phecode <PHECODE> --pop <POP> --rsid <RSID> --token <TOKEN>
```

- Phecode and Population arguments are required - See Wiki 4. Retrieving Summary Statistics for phecode and population options
- rsid and token arguments are optional
> To view a locus with locuszoomr other than the locus with the lowest P-value SNP, specify the rsID of a SNP within the locus of interest. This SNP will also serve as the reference SNP for linkage disequilibrium disply

> Token represents the LDlink personal access code needed to display linkage disequilibrium when plotting with locuszoomr. To make a one-time request for your personal access token follow the directions within the following web browser at https://ldlink.nih.gov/?tab=apiaccess.

### 00twas-wrapper
This second wrapper performs the TWAS part of this tool. It executes setting up S-PrediXcan and scripts 5 & 6, which imputes TWAS summary statistics and generates a Manhattan plot of those data.

**MUST BE PERFORMED AT LEAST ONCE PRIOR TO RUNNING S-PREDIXCAN:**
1. Run in AoU terminal: `chmod +x ~/aou_predixcan/00twas-wrapper.sh`
2. Run in AoU terminal: `gsutil ls` to find bucket name -> ex. `gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b`
3. Run in lab server terminal: `gsutil -m cp -v /home/wheelerlab3/Data/predictdb_models/elastic-net-with-phi.tar {PASTE_YOUR_BUCKET_HERE}/data/` -> ex. `gsutil -m cp -v //home/wheelerlab3/Data/predictdb_models/elastic-net-with-phi.tar gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b/data/`

Run the wrapper via
```
bash ~/aou_predixcan/00twas-wrapper.sh --phecode <PHECODE> --pop <POP> --ref <REF>
```

`<PHECODE>` is the phenotype code of interest  
`<POP>` is the population the sample originates from  
`<REF>` is the reference database to use  

- Database files from /home/claudia/aou_predixcan/mesa_dbfiles are used for S-PrediXcan analysis
  - To upload: `gsutil -m cp -r /home/claudia/aou_predixcan/mesa_dbfiles {PASTE_YOUR_BUCKET_HERE}/data/`
***
