import os
import sys
import argparse
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
    
    #save heritability and sample size from user input
    h2 = args.gwas_h2
    n_total = args.gwas_N
    
    #if either value is not provided by user, try to get it from the Hail table
    if h2 is None or n_total is None:
        #store original numpy version
        original_numpy = None
        try:
            import numpy
            original_numpy = numpy.__version__
            
            #install higher numpy version for Hail
            subprocess.check_call([sys.executable, "-m", "pip", "install", "numpy>=1.20.3", "--force-reinstall", "--quiet"])
            
            import hail as hl
            #initialize hail and read in table
            hl.init()
            ht = hl.read_table(f"gs://fc-aou-datasets-controlled/AllxAll/v1/ht/ACAF/{pop}/phenotype_{phenotype_id}_ACAF_results.ht")
            
            print("Available globals:\n")
            ht.describe()
            
            #get values from table if not provided by user
            if h2 is None:
                h2 = ht.globals.heritability.collect()[0]
            
            if n_total is None:
                n_cases = ht.globals.n_cases.collect()[0]
                n_controls = ht.globals.n_controls.collect()[0]
                print(f'Cases/Controls/Heritability will print "None" if no information is connected to the hail table\n')
                print(f"Cases: {n_cases}, Controls: {n_controls}\n")
                
                #only set n_total if both values are not None
                if n_cases is not None and n_controls is not None:
                    n_total = n_cases + n_controls
            
            if h2 is not None:
                print(f"Heritability: {h2}\n")
                
            print(f'Any "None" values are excluded from analysis; proceeding with S-PrediXcan analysis\n')
            
        except Exception as e:
            print(f"Error accessing Hail data: {e}")
            print("Proceeding with available command-line values only.")
        
        finally:
            #restore original numpy version for MetaXcan compatibility
            if original_numpy:
                subprocess.check_call([sys.executable, "-m", "pip", "install", f"numpy=={original_numpy}", "--force-reinstall", "--quiet"])
                # Force reload of numpy
                if 'numpy' in sys.modules:
                    del sys.modules['numpy']
                import numpy
        
    #get gtex formatted file from bucket
    bucket = os.getenv('WORKSPACE_BUCKET')
    filename = args.pop + "_formatted_gtex_" + args.phecode + ".tsv"
    get_command = "gsutil cp " + bucket + "/data/" + filename + " /tmp/"
    os.system(get_command)
    
    #output file location and name
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
