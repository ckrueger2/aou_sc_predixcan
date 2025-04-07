import os
import argparse

parser = argparse.ArgumentParser(description="run s-predixcan")
parser.add_argument("-i", "--input", help="input file", required=True)
parser.add_argument("-o", "--output", help="output file", required=True)
args = parser.parse_args()

output = "predixcan-results/hack-test.csv"
input = "cleaned_TESTDATA_hacking.txt"

os.chdir("MetaXcan/software")

model = "allofus_test/eqtl/mashr/mashr_Stomach.db"
matrix = "allofus_test/eqtl/mashr/mashr_Stomach.txt.gz"
infile = f"../../{args.input}"
outfile = f"../../{args.output}"

os.system(f"./SPrediXcan.py \
--model_db_path {model} \
--covariance {matrix} \
--gwas_file {infile} \
--snp_column locus \
--effect_allele_column effect_allele \
--non_effect_allele_column other_allele \
--beta_column beta \
--pvalue_column Pvalue \
--se_column standard_error \
--or_column odds_ratio \
--output_file {outfile}")