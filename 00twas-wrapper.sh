#!/bin/bash

#command
usage() {
    echo "Usage: $0 --phecode <PHECODE> --pop <POP> --ref <REF> [--gwas_h2 <H2>] [--gwas_N <N>] [--databases]"
    exit 1
}
        
TISSUES="Adipose_Subcutaneous\nAdipose_Visceral_Omentum\nAdrenal_Gland\nArtery_Aorta\nArtery_Coronary\nArtery_Tibial\nBrain_Amygdala\nBrain_Anterior_cingulate_cortex_BA24\nBrain_Caudate_basal_ganglia\nBrain_Cerebellar_Hemisphere\nBrain_Cerebellum\nBrain_Cortex\nBrain_Frontal_Cortex_BA9\nBrain_Hippocampus\nBrain_Hypothalamus\nBrain_Nucleus_accumbens_basal_ganglia\nBrain_Putamen_basal_ganglia\nBrain_Spinal_cord_cervical_c-1\nBrain_Substantia_nigra\nBreast_Mammary_Tissue\nCells_Cultured_fibroblasts\nCells_EBV-transformed_lymphocytes\nColon_Sigmoid\nColon_Transverse\nEsophagus_Gastroesophageal_Junction\nEsophagus_Mucosa\nEsophagus_Muscularis\nHeart_Atrial_Appendage\nHeart_Left_Ventricle\nKidney_Cortex\nLiver\nLung\nMinor_Salivary_Gland\nMuscle_Skeletal\nNerve_Tibial\nOvary\nPancreas\nPituitary\nProstate\nSkin_Not_Sun_Exposed_Suprapubic\nSkin_Sun_Exposed_Lower_leg\nSmall_Intestine_Terminal_Ileum\nSpleen\nStomach\nTestis\nThyroid\nUterus\nVagina\nWhole_Blood"

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
        --gwas_h2)
            H2=$2
            shift 2
            ;;
        --gwas_N)
            N=$2
            shift 2
            ;;
        --databases)
            echo -e "$TISSUES"
            shift 1
            ;;
        *)
            echo "unknown flag: $1"
            usage
            ;;
    esac
done

#check for required arguments
if [[ -z "$PHECODE" || -z "$POP" || -z "$REF" ]]; then
    usage
fi

#github repo path
REPO=$HOME/GWAS-TWAS-in-All-of-Us-Cloud

#set up S-PrediXcan environment
bash "$REPO/set-up-predixcan.sh"

#activate conda
source ~/miniconda3/bin/activate

#remove existing imlabtools if it exists
if conda env list | grep -q imlabtools; then
    conda env remove -n imlabtools -y
fi

#create environment with compatible versions (this may need to be changed with future updates)
conda create -n imlabtools python=3.8 numpy=1.19 pandas=1.1 scipy -y

#activate imlabtools
if conda activate imlabtools; then
    echo "Successfully activated imlabtools environment"
fi

#patch metaxcan code if needed
if [ -f /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py ]; then
    #replace 'numpy.str' with 'numpy.str_'
    sed -i 's/numpy\.str\([^_]\)/numpy.str_\1/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    
    # verify the file doesn't contain any malformed replacements
    if grep -q "numpy\.str_____" /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py; then
        echo "WARNING: Found incorrect replacement in Utilities.py, fixing..."
        sed -i 's/numpy\.str_____/numpy.str_/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    fi
    
    #double-check for any other incorrect replacements
    if grep -q "numpy\.str__" /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py; then
        echo "WARNING: Found other incorrect replacements in Utilities.py, fixing..."
        sed -i 's/numpy\.str__/numpy.str_/g' /home/jupyter/MetaXcan/software/metax/metaxcan/Utilities.py
    fi
fi

output_file="/home/jupyter/${POP}_predixcan_output_${PHECODE}.csv"

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
PREDIXCAN_CMD="python $REPO/05run-predixcan.py --phecode \"$PHECODE\" --pop \"$POP\" --ref \"$REF\""
if [[ ! -z "$H2" ]]; then
    PREDIXCAN_CMD="$PREDIXCAN_CMD --gwas_h2 \"$H2\""
fi
if [[ ! -z "$N" ]]; then
    PREDIXCAN_CMD="$PREDIXCAN_CMD --gwas_N \"$N\""
fi
eval $PREDIXCAN_CMD

#run qqman on twas sum stats
Rscript "$REPO/06twas_qqman.R" --phecode "$PHECODE" --pop "$POP"

#deactivate imlabtools
conda deactivate

#how to view generated PNG files
echo "To view the S-PrediXcan and PNG files, go to the Jupyter file browser by selecting the jupyter logo to the top left of the terminal."
