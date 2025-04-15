import os
import sys
import argparse

def get_arguments(args=None):
    parser = argparse.ArgumentParser(description="run s-predixcan")
    parser.add_argument("-i", "--input", help="path to input file", required=False)
    parser.add_argument("-o", "--output", help="where to make output file", required=False)
    parser.add_argument("-r", "--reference", help="eqtl model and matrix to use as reference", required=False)
    parser.add_argument("--databases", help="list possible inputs for --reference option", required=False)
    return parser.parse_args(args)

def main():
    args = get_arguments(sys.argv[1:])

    d = ["Adipose_Subcutaneous", "Adipose_Visceral_Omentum", "Adrenal_Gland", "Artery_Aorta", "Artery_Coronary", "Artery_Tibial", 
    "Brain_Amygdala", "Brain_Anterior_cingulate_cortex_BA24", "Brain_Caudate_basal_ganglia", "Brain_Cerebellar_Hemisphere", 
    "Brain_Cerebellum", "Brain_Cortex", "Brain_Frontal_Cortex_BA9", "Brain_Hippocampus", "Brain_Hypothalamus", 
    "Brain_Nucleus_accumbens_basal_ganglia", "Brain_Putamen_basal_ganglia", "Brain_Spinal_cord_cervical_c-1", "Brain_Substantia_nigra", 
    "Breast_Mammary_Tissue", "Cells_Cultured_fibroblasts", "Cells_EBV-transformed_lymphocytes", "Colon_Sigmoid", "Colon_Transverse", 
    "Esophagus_Gastroesophageal_Junction", "Esophagus_Mucosa", "Esophagus_Muscularis", "Heart_Atrial_Appendage", 
    "Heart_Left_Ventricle", "Kidney_Cortex", "Liver", "Lung", "Minor_Salivary_Gland", "Muscle_Skeletal", "Nerve_Tibial", "Ovary", 
    "Pancreas", "Pituitary", "Prostate", "Skin_Not_Sun_Exposed_Suprapubic", "Skin_Sun_Exposed_Lower_leg", 
    "Small_Intestine_Terminal_Ileum", "Spleen", "Stomach", "Testis", "Thyroid", "Uterus", "Vagina", "Whole_Blood"]

    if args.databases:
        for ref in d:
            print(d)
        return

    if not args.input or not args.output or not args.reference:
        print("missing required arguments")
    else:
        os.system(f"conda run -p /home/jupyter/miniconda3/envs/imlabtools \
        python MetaXcan/software/SPrediXcan.py \
        --gwas_file {args.input} \
        --snp_column SNP \
        --effect_allele_column ALT \
        --non_effect_allele_column REF \
        --beta_column BETA \
        --se_column SE \
        --model_db_path eqtl/mashr/mashr_{args.reference}.db \
        --covariance eqtl/mashr/mashr_{args.reference}.txt.gz \
        --keep_non_rsid \
        --additional_output \
        --model_db_snp_key varID \
        --throw \
        --output_file {args.output}.csv")

if __name__ == "__main__":
    main()