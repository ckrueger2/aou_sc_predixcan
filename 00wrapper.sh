#!/bin/bash

#command
usage() {
    echo "Usage: $0 --phecode <PHECODE> --pop <POP> --ref <REF> --cell_type <TYPE>"
    exit 1
}

#command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --phecode)
            PHECODE=$2
            shift 2
            ;;
        --pop)
            POP=$2
            shift 2
            ;;
        --ref)
            REF=$2
            shift 2
            ;;
        --cell_type)
            TYPE=$2
            shift 2
            ;;
        *)
            echo "unknown flag: $1"
            usage
            ;;
    esac
done

#check for required arguments
if [[ -z "$PHECODE" || -z "$POP" || -z "$REF" || -z "$TYPE" ]]; then
    usage
fi

#github repo path
REPO=$HOME/aou_sc_predixcan

#download hail table
python "$REPO/01pull_data.py" --phecode "$PHECODE" --pop "$POP"

#format hail tables
Rscript "$REPO/02table_format.R" --phecode "$PHECODE" --pop "$POP" --cell_type "$TYPE"

#set up S-PrediXcan environment
bash "$REPO/set-up-predixcan.sh"

#activate conda
source ~/miniconda3/bin/activate

#create environment with compatible versions (version numbers may need to be changed with future updates)
if ! conda env list | grep -q imlabtools; then
    # If it doesn't exist, create it
    conda create -n imlabtools python=3.8 numpy pandas scipy -y
fi

#activate imlabtools
if conda activate imlabtools; then
    echo "Successfully activated imlabtools environment"
fi

#patch MetaXcan code
if [ -f /home/jupyter/MetaXcan/software/metax/gwas/GWAS.py ]; then
    sed -i 's/if a.dtype == numpy.object:/if a.dtype == object or str(a.dtype).startswith("object"):/' /home/jupyter/MetaXcan/software/metax/gwas/GWAS.py
fi

#patch numpy.str deprecation in Utilities.py
if [ -f /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py ]; then
    # First check if the file contains the original numpy.str (not already patched)
    if grep -q "numpy\.str[^_]" /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py; then
        # Only replace numpy.str with numpy.str_ if it hasn't been replaced yet
        sed -i 's/numpy\.str\([^_]\)/numpy.str_\1/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    elif grep -q "numpy\.str_" /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py; then
        # If we find numpy.str__ (double underscore), replace it with numpy.str_
        sed -i 's/numpy\.str__/numpy.str_/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    fi
    
    # Fix the specific line that causes errors with numpy.str__
    sed -i 's/type = \[numpy\.str[_]*, numpy\.float64, numpy\.float64, numpy\.float64\]/type = \[str, numpy.float64, numpy.float64, numpy.float64\]/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    
    # Fix pandas drop() method call
    sed -i 's/results = results.drop("n_snps_in_model",1)/results = results.drop(columns=["n_snps_in_model"])/' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
fi

output_file="/home/jupyter/${POP}_predixcan_output_${PHECODE}_${TYPE}_cell_${REF}.csv"

#check if the output file already exists
if [ -f "$output_file" ]; then
    echo "WARNING: Output file $output_file already exists."
    read -p "Press ENTER to replace it, or type 'n' to cancel: " response
    
    if [[ $response =~ ^[Nn]$ ]]; then
        echo "Operation cancelled by user."
        exit 1
    else
        # Delete the file
        rm -f "$output_file"
        echo "Existing file has been deleted."
    fi
fi

#run s-predixcan
python $REPO/03run_predixcan.py --phecode "$PHECODE" --pop "$POP" --ref "$REF" --cell_type "$TYPE"

#deactivate imlabtools
conda deactivate
