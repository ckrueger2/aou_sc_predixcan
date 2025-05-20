import os
import sys
import argparse
import hail as hl
import subprocess

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
    phenotype_id = args.phecode
    pop = args.pop
    
    #initialize heritability and sample size from user input
    h2 = args.gwas_h2
    n_total = args.gwas_N
    
    #get file from bucket
    bucket = os.getenv('WORKSPACE_BUCKET')
    filename = args.pop + "_formatted_gtex_" + args.phecode + ".tsv"
    get_command = "gsutil cp " + bucket + "/data/" + filename + " /tmp/"
    os.system(get_command)
    
    output = f"/home/jupyter/{args.pop}_predixcan_output_{args.phecode}.csv"
    #define python and metaxcan paths
    python_path = sys.executable
    metaxcan_dir = "/home/jupyter/MetaXcan"
    
    #build the command with optional parameters
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
    if h2 is not None:
        cmd += f" \\\n    --gwas_h2 {h2}"
    
    #add sample size parameter if available
    if n_total is not None:
        cmd += f" \\\n    --gwas_N {n_total}"
    
    #add output file and execute command
    cmd += f" \\\n    --output_file {output}"
    os.system(cmd)
    
    set_file = "gsutil cp " + output + " " + bucket + "/data/"
    os.system(set_file)

if __name__ == "__main__":
    main()
