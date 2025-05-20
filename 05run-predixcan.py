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
        try:
            #create a temporary script to run in a separate process with higher numpy version
            temp_script = "/tmp/get_hail_values.py"
            with open(temp_script, "w") as f:
                f.write(f"""
import sys
import os
import json
import hail as hl

try:
    hl.init()
    ht = hl.read_table("gs://fc-aou-datasets-controlled/AllxAll/v1/ht/ACAF/{pop}/phenotype_{phenotype_id}_ACAF_results.ht")
    
    print("Available globals:")
    ht.describe()
    
    h2 = ht.globals.heritability.collect()[0]
    n_cases = ht.globals.n_cases.collect()[0]
    n_controls = ht.globals.n_controls.collect()[0]
    
    print(f'Cases/Controls/Heritability will print "None" if no information is connected to the hail table')
    print(f"Cases: {{n_cases}}, Controls: {{n_controls}}")
    
    if h2 is not None:
        print(f"Heritability: {{h2}}")
    
    result = {{
        "h2": h2,
        "n_cases": n_cases,
        "n_controls": n_controls
    }}
    
    print(f'Any "None" values are excluded from analysis; proceeding with S-PrediXcan analysis')
    
    with open('/tmp/hail_values.json', 'w') as f:
        json.dump(result, f)
    
    print(f'Any "None" values are excluded from analysis; proceeding with S-PrediXcan analysis')
    sys.exit(0)
except Exception as e:
    print(f"Error: {{str(e)}}")
    sys.exit(1)
""")
            
            #run the script in a temporary environment with correct dependencies
            print("Sample size or heritability not provided; running Hail in a separate process...")
            cmd = f"cd /tmp && pip install hail numpy>=1.20.3 --quiet && python {temp_script}"
            subprocess.run(cmd, shell=True, check=False)
            
            #read the JSON from file instead of trying to parse stdout
            if os.path.exists('/tmp/hail_values.json'):
                with open('/tmp/hail_values.json', 'r') as f:
                    hail_values = json.load(f)
                
                #set h2 if not provided and available from Hail
                if h2 is None and "h2" in hail_values and hail_values["h2"] is not None:
                    h2 = hail_values["h2"]
                    print(f"Using heritability from Hail: {h2}")
                
                #calculate n_total if not provided and components available from Hail
                if n_total is None and "n_cases" in hail_values and "n_controls" in hail_values:
                    n_cases = hail_values["n_cases"]
                    n_controls = hail_values["n_controls"]
                    
                    if n_cases is not None and n_controls is not None:
                        n_total = n_cases + n_controls
                        print(f"Using sample size from Hail: {n_total}")
            
            #clean up
            if os.path.exists(temp_script):
                os.remove(temp_script)
            if os.path.exists('/tmp/hail_values.json'):
                os.remove('/tmp/hail_values.json')
                
        except Exception as e:
            print(f"Error accessing Hail data: {e}")
            print("Proceeding with available command-line values only.")
                
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
