#!/usr/bin/env python3

import os
import sys
import argparse
import subprocess

def set_args():
    parser = argparse.ArgumentParser(description="run s-predixcan")
    parser.add_argument("--phecode", help="phecode", required=True)
    parser.add_argument("--pop", help="population", required=True)
    parser.add_argument("--ref", help="model and matrix to use as ref", required=True)
    parser.add_argument("--cell_type", help="single cell model to use", required=True)
    return parser
    
def main():
    parser = set_args()
    args = parser.parse_args(sys.argv[1:])
    
    #define paths
    bucket = os.getenv('WORKSPACE_BUCKET')
    
    #python and metaxcan paths
    python_path = sys.executable
    metaxcan_dir = "/home/jupyter/MetaXcan"
    
    #retrieve single cell filtered file from bucket
    filename = args.pop + "_formatted_sc_" + args.cell_type + "_" + args.phecode + ".tsv"
    get_command = "gsutil cp " + bucket + "/data/" + filename + " /tmp/"
    os.system(get_command)
    
    #build command based on parameters
    if args.cell_type == "islet":
        output = f"/home/jupyter/{args.pop}_predixcan_output_{args.phecode}_islet_cell_{args.ref}.csv"

        #copy single cell dbfiles
        os.makedirs("/home/jupyter/l-ctPred_models/", exist_ok=True)
        copy_command = f"gsutil cp -r {bucket}/data/l-ctPred_models_for_islet_cell_types_from_T2D_dataset/{args.ref}* /home/jupyter/l-ctPred_models/", shell=True)

        #command without optional parameters
        cmd = f"{python_path} {metaxcan_dir}/software/SPrediXcan.py \
        --gwas_file /tmp/{filename} \
        --snp_column SNP \
        --effect_allele_column ALT \
        --non_effect_allele_column REF \
        --beta_column BETA \
        --se_column SE \
        --model_db_path l-ctPred_models/{args.ref}.db \
        --covariance l-ctPred_models/{args.ref}_covariances.txt.gz \
        --keep_non_rsid \
        --model_db_snp_key rsid \
        --throw \
        --output_file {output}"
    elif args.cell_type == "immune":
        output = f"/home/jupyter/{args.pop}_predixcan_output_{args.phecode}_immune_cell_{args.ref}.csv"
        
        #copy single cell dbfiles
        os.makedirs("/home/jupyter/l-ctPred_models/", exist_ok=True)
        copy_command = f"gsutil cp -r {bucket}/data/l-ctPred_models_for_immune_cell_types_from_OneK1K_dataset/{args.ref}* /home/jupyter/l-ctPred_models/", shell=True)
        
        #command without optional parameters
        cmd = f"{python_path} {metaxcan_dir}/software/SPrediXcan.py \
        --gwas_file /tmp/{filename} \
        --snp_column SNP \
        --effect_allele_column ALT \
        --non_effect_allele_column REF \
        --beta_column BETA \
        --se_column SE \
        --model_db_path l-ctPred_models/{args.ref}.db \
        --covariance l-ctPred_models/{args.ref}_covariances.txt.gz \
        --keep_non_rsid \
        --model_db_snp_key rsid \
        --throw \
        --output_file {output}"
        
    else:
        print("ERROR: Cell type not found (options are islet or immune)")
        
    #execute the S-PrediXcan command
    print("Running S-PrediXcan...")
    exit_code = os.system(cmd)
    
    if exit_code != 0:
        print(f"ERROR: SPrediXcan.py failed with exit code {exit_code}")
        return
    
    #upload the results back to the bucket
    set_file = f"gsutil cp {output} {bucket}/data/"
    print(f"Uploading results: {set_file}")
    os.system(set_file)
    
    #remove database files
    if os.path.exists("/home/jupyter/l-ctPred_models"):
        os.system("rm -rf /home/jupyter/l-ctPred_models")

    print("S-PrediXcan analysis completed successfully")

if __name__ == "__main__":
    main()
