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

    bucket = os.environ.get("WORKSPACE_BUCKET")

    os.system(f"conda run -p /home/jupyter/miniconda3/envs/imlabtools \
    python MetaXcan/software/SPrediXcan.py \
    --gwas_file {input} \
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
    --output_file {args.pop}_predixcan_output_{args.phecode}.csv")

if __name__ == "__main__":
    main()