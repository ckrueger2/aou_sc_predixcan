import os
import sys
import argparse

def set_args():
    parser = argparse.ArgumentParser(description="run s-predixcan")
    parser.add_argument("--phecode", help="phecode", required=True)
    parser.add_argument("--pop", help="population", required=True)
    parser.add_argument("-r", "--reference", help="eqtl model and matrix to use as reference", required=True)
    return parser

def main():
    parser = set_args()
    args = parser.parse_args(sys.argv[1:])

    #get file from bucket
    bucket = os.environ.get("WORKSPACE_BUCKET")
    filename = args.pop + "_formatted_gtex_" + args.phecode + ".tsv"
    get_file = "gsutil cp " + bucket + "/data/" + filename + " ."
    
    os.system(get_file)
    output = f"{args.pop}_predixcan_output_{args.phecode}.csv"

    #use system Python if conda environment Python isn't found
    python_path = "/home/jupyter/miniconda3/envs/imlabtools/bin/python"
    if not os.path.exists(python_path):
        print(f"Warning: {python_path} not found, using system Python")
        python_path = "python"
    
    os.system(f"{python_path} MetaXcan/software/SPrediXcan.py \
    --gwas_file /home/jupyter/GWAS-TWAS-in-All-of-Us-Cloud/{filename} \
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
    --output_file {output}")

    set_file = "gsutil cp " + output + " " + bucket + "/data/"
    os.system(set_file)

if __name__ == "__main__":
    main()
