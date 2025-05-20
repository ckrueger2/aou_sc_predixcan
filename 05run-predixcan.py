#!/usr/bin/env python3

import os
import sys
import argparse

def set_args():
    parser = argparse.ArgumentParser(description="run s-predixcan")
    parser.add_argument("--phecode", help="phecode", required=True)
    parser.add_argument("--pop", help="population", required=True)
    parser.add_argument("--ref", help="eqtl model and matrix to use as ref", required=True)
    parser.add_argument("--gwas_h2", help="heritability value (optional)", type=float)
    parser.add_argument("--gwas_N", help="total sample size (optional)", type=int)
    return parser
    
def main():
    parser = set_args()
    args = parser.parse_args(sys.argv[1:])
    
    #retrieve file from bucket
    bucket = os.getenv('WORKSPACE_BUCKET')
    filename = args.pop + "_formatted_gtex_" + args.phecode + ".tsv"
    get_command = "gsutil cp " + bucket + "/data/" + filename + " /tmp/"
    os.system(get_command)
    
    output = f"/home/jupyter/{args.pop}_predixcan_output_{args.phecode}.csv"
    
    #python and metaxcan paths
    python_path = sys.executable
    metaxcan_dir = "/home/jupyter/MetaXcan"
    
    #build the command
    cmd = f"{python_path} {metaxcan_dir}/software/SPrediXcan.py \
    --gwas_file /tmp/{filename} \
    --snp_column SNP \
    --effect_allele_column ALT \
    --non_effect_allele_column REF \
    --beta_column BETA \
    --se_column SE \
    --model_db_path eqtl/mashr/mashr_{args.ref}.db \
    --covariance eqtl/mashr/mashr_{args.ref}.txt.gz \
    --keep_non_rsid \
    --additional_output \
    --model_db_snp_key varID \
    --throw"
    
    #add heritability parameter if available
    if args.gwas_h2 is not None:
        cmd += f" \\\n    --gwas_h2 {args.gwas_h2}"
    
    #add sample size parameter if available
    if args.gwas_N is not None:
        cmd += f" \\\n    --gwas_N {args.gwas_N}"
        
    #execute the S-PrediXcan command
    os.system(cmd)
    
    #copy output to bucket
    set_file = "gsutil cp " + output + " " + bucket + "/data/"
    os.system(set_file)

if __name__ == "__main__":
    main()
