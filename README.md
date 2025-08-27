# All of Us Single Cell S-PrediXcan
***
Github for scPrediXcan: https://github.com/hakyimlab/scPrediXcan

Installing pipeline in All of Us:   
`git clone https://github.com/ckrueger2/aou_sc_predixcan`

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
1. Create virtual machine with the following parameters (select jupyter icon on right tool bar):
   - Select `Hail Genomics Analysis` under `Recomended environments` drop down
   - Select `16` under `Cloud compute profile CPUs`
   - Select `60` under `Cloud compute profile RAM (GB)`
2. Run in AoU terminal: `gsutil ls` to find bucket name -> ex. `gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b`
3. Run in AoU terminal: `gcloud config get-value project` to find project Terra ID
4. Run in lab server terminal: `gcloud auth login`, then follow prompts to log into AoU account
5. Run in lab server terminal: `gcloud config set project {PASTE_YOUR_TERRA_ID_HERE}`
6. Run in lab server terminal: `gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_immune_cell_types_from_OneK1K_dataset/ {PASTE_YOUR_BUCKET_HERE}/data/` -> ex. `gsutil -m cp -v gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_immune_cell_types_from_OneK1K_dataset/ gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b/data/`
7. Run in lab server terminal: `gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_islet_cell_types_from_OneK1K_dataset/ {PASTE_YOUR_BUCKET_HERE}/data/` -> ex. `gsutil -m cp -v gsutil -m cp -r -v /home/wheelerlab3/Data/predictdb_models/scPrediXcan_models/l-ctPred_models_for_islet_cell_types_from_T2D_dataset/ gs://fc-secure-d80c2561-4630-4343-ab98-9fb7fcc9c21b/data/`
8. The wrapper must be ran at least once. After one successful run (at least to where S-PrediXcan begins to run and `Running S-PrediXcan...` is printed in output), then the 03run_predixcan.py script can be run with different references databases without re-running the full wrapper with `python ~/aou_sc_predixcan/03run_predixcan.py --phecode <PHECODE> --pop <POP> --ref <REF> --cell_type <TYPE>`

`<PHECODE>` is the phenotype code of interest (ex. CV_404)  
`<POP>` is the population the sample originates from (ex. META)  
`<REF>` is the reference database to use (ex. CD14-low_CD16-positive_monocyte)  
`<TYPE>` is the single cell database to use (immune or islet)  

A list of available phenotype accession numbers: https://docs.google.com/spreadsheets/d/e/2PACX-1vT6SQhuX1xO-f2SOg7m5UoPmapKI3lnSb7xYRt9Vn6bYvaFevz16Ou2gsPfQPnjvJZ_DczJhOdfsKfg/pub?output=xlsx

Available reference database flags for immune cell types from OneK1K dataset:   
--ref CD14-low_CD16-positive_monocyte --cell_type immune   
--ref CD14-positive_monocyte --cell_type immune   
--ref CD16-negative_CD56-bright_natural_killer_cell_human --cell_type immune   
--ref CD4-positive_alpha-beta_cytotoxic_T_cell --cell_type immune   
--ref CD4-positive_alpha-beta_T_cell --cell_type immune   
--ref CD8-positive_alpha-beta_T_cell --cell_type immune   
--ref central_memory_CD4-positive_alpha-beta_T_cell --cell_type immune   
--ref central_memory_CD8-positive_alpha-beta_T_cell --cell_type immune   
--ref conventional_dendritic_cell --cell_type immune   
--ref dendritic_cell --cell_type immune   
--ref double_negative_thymocyte --cell_type immune   
--ref effector_memory_CD4-positive_alpha-beta_T_cell --cell_type immune   
--ref effector_memory_CD8-positive_alpha-beta_T_cell --cell_type immune   
--ref erythrocyte --cell_type immune   
--ref gamma-delta_T_cell --cell_type immune   
--ref hematopoietic_precursor_cell --cell_type immune   
--ref innate_lymphoid_cell --cell_type immune   
--ref memory_B_cell --cell_type immune   
--ref mucosal_invariant_T_cell --cell_type immune   
--ref naive_thymus-derived_CD4-positive_alpha-beta_T_cell --cell_type immune   
--ref naive_thymus-derived_CD8-positive_alpha-beta_T_cell --cell_type immune   
--ref natural_killer_cell --cell_type immune   
--ref peripheral_blood_mononuclear_cell --cell_type immune   
--ref plasmablast --cell_type immune   
--ref plasmacytoid_dendritic_cell --cell_type immune   
--ref platelet --cell_type immune   
--ref regulatory_T_cell --cell_type immune   
--ref transitional_stage_B_cell --cell_type immune

Available reference database flags for islet cell types from T2D dataset:   
--ref Acinar --cell_type islet   
--ref Activated_stellate --cell_type islet   
--ref Alpha --cell_type islet   
--ref Beta --cell_type islet   
--ref Delta --cell_type islet   
--ref Ductal --cell_type islet   
--ref Endothelial --cell_type islet   
--ref Epsilon --cell_type islet   
--ref Gamma --cell_type islet   
--ref Immune --cell_type islet   
--ref Quiescent_stellate --cell_type islet

Example command:
```
bash ~/aou_sc_predixcan/00wrapper.sh --phecode CV_404 --pop META --ref CD14-low_CD16-positive_monocyte --cell_type immune
```
***
