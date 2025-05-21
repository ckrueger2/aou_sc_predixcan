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
    
    #retrieve gtex filtered file from bucket
    bucket = os.getenv('WORKSPACE_BUCKET')
    filename = args.pop + "_formatted_gtex_" + args.phecode + ".tsv"
    get_command = "gsutil cp " + bucket + "/data/" + filename + " /tmp/"
    os.system(get_command)
    
    output = f"/home/jupyter/{args.pop}_predixcan_output_{args.phecode}.csv"
    
    #python and metaxcan paths
    python_path = sys.executable
    metaxcan_dir = "/home/jupyter/MetaXcan"

    #build command based on parameters
    if args.gwas_h2 is not None and args.gwas_N is not None:
        #retrieve gtex reference files from bucket
        os.system(f"gsutil cp {bucket}/data/elastic-net-with-phi.tar /tmp/")
        os.system("tar -xf /tmp/elastic-net-with-phi.tar -C /tmp/") #fixed the brackets issue

        #command with optional parameters
        cmd = f"{python_path} {metaxcan_dir}/software/SPrediXcan.py \
        --gwas_file /tmp/{filename} \
        --snp_column SNP \
        --effect_allele_column ALT \
        --non_effect_allele_column REF \
        --beta_column BETA \
        --se_column SE \
        --model_db_path /tmp/elastic-net-with-phi/en_{args.ref}.db \
        --covariance /tmp/elastic-net-with-phi/en_{args.ref}.txt.gz \
        --keep_non_rsid \
        --additional_output \
        --model_db_snp_key varID \
        --throw \
        --output_file {output}"
        
        #add heritability parameter if available
        if args.gwas_h2 is not None:
            cmd += f" \\\n    --gwas_h2 {args.gwas_h2}"
        
        #add sample size parameter if available
        if args.gwas_N is not None:
            cmd += f" \\\n    --gwas_N {args.gwas_N}"
    else:
        #command without optional parameters
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
        --model_db_snp_key varID \
        --throw \
        --output_file {output}"
        
    #execute the S-PrediXcan command
    exit_code = os.system(cmd)
    
    if exit_code != 0:
        print(f"ERROR: SPrediXcan.py failed with exit code {exit_code}")
        return
    
    #upload the results back to the bucket
    set_file = f"gsutil cp {output} {bucket}/data/"
    print(f"Uploading results: {set_file}")
    os.system(set_file)

    #clean up tmp files if they exist
    if args.gwas_h2 is not None and args.gwas_N is not None:
        os.system("rm -rf /tmp/elastic-net-with-phi /tmp/eqtl /tmp/elastic-net-with-phi.tar 2>/dev/null")
        
    print("S-PrediXcan analysis completed successfully")

if __name__ == "__main__":
    main()
