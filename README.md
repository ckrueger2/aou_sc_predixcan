# All of Us Single Cell S-PrediXcan
***
### 00Wrapper
Prior to running the 00wrapper.sh script, run
```
chmod +x ~/aou_sc_predixcan/00wrapper.sh
```

Running the 00Wrapper.sh will execute scripts 1 through 3, which include pulling GWAS summary statistics, formatting them, and running single cell S-PrediXcan

To run the wrapper use the following command within the All of Us terminal under the Hail Table Environment:
```
bash ~/aou_sc_predixcan/00wrapper.sh --phecode <PHECODE> --pop <POP> --ref <REF> --cell_type <TYPE>
```

**MUST BE PERFORMED AT LEAST ONCE PRIOR TO RUNNING S-PREDIXCAN:**
1. Run in AoU terminal: `chmod +x ~/aou_predixcan/00twas_wrapper.sh`
2. Run in AoU terminal: `gsutil ls` to find bucket name -> ex. `gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b`
3. Run in lab server terminal: `gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_immune_cell_types_from_OneK1K_dataset/ {PASTE_YOUR_BUCKET_HERE}/data/` -> ex. `gsutil -m cp -v gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_immune_cell_types_from_OneK1K_dataset/ gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b/data/`
4. Run in lab server terminal: `gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_islet_cell_types_from_OneK1K_dataset/ {PASTE_YOUR_BUCKET_HERE}/data/` -> ex. `gsutil -m cp -v gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_islet_cell_types_from_T2D_dataset/ gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b/data/`

`<PHECODE>` is the phenotype code of interest (ex. CV_404)

`<POP>` is the population the sample originates from (ex. META)

`<REF>` is the reference database to use (ex. CD14-low_CD16-positive_monocyte)

`<TYPE>` is the single cell database to use (immune cell or islet cell)

A list of available phenotype accession numbers: https://docs.google.com/spreadsheets/d/e/2PACX-1vT6SQhuX1xO-f2SOg7m5UoPmapKI3lnSb7xYRt9Vn6bYvaFevz16Ou2gsPfQPnjvJZ_DczJhOdfsKfg/pub?output=xlsx

Example command:
```
bash ~/aou_sc_predixcan/00wrapper.sh --phecode CV_404 --pop META --ref CD14-low_CD16-positive_monocyte --cell_type immune
```
***
