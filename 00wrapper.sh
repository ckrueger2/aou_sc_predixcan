#!/bin/bash

#command
usage() {
    echo "Usage: $0 --phecode <PHECODE> --pop <POP> [--rsid <RSID>] [--token <TOKEN>]"
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
        --rsid)
            RSID=$2
            shift 2
            ;;
        --token)
            TOKEN=$2
            shift 2
            ;;
        *)
            echo "unknown flag: $1"
            usage
            ;;
    esac
done

#check for required arguments
if [[ -z "$PHECODE" || -z "$POP" ]]; then
    usage
fi

#github repo path
REPO=$HOME/GWAS-TWAS-in-All-of-Us-Cloud

#download hail table
python "$REPO/01pull_data.py" --phecode "$PHECODE" --pop "$POP"
#capture the SNP count
SNP_COUNT=$(python "$REPO/01pull_data.py" --phecode "$PHECODE" --pop "$POP" | tail -n 1)

#format hail tables
Rscript "$REPO/02table_format.R" --phecode "$PHECODE" --pop "$POP"

#GWAS qqman
Rscript "$REPO/03qqman.R" --phecode "$PHECODE" --pop "$POP" --snp_count "$SNP_COUNT"

#locuszoomR
LOCUSZOOM_CMD="Rscript $REPO/04locuszoom.R --phecode \"$PHECODE\" --pop \"$POP\""
if [[ ! -z "$RSID" ]]; then
    LOCUSZOOM_CMD="$LOCUSZOOM_CMD --rsid \"$RSID\""
fi
if [[ ! -z "$TOKEN" ]]; then
    LOCUSZOOM_CMD="$LOCUSZOOM_CMD --token \"$TOKEN\""
fi
eval $LOCUSZOOM_CMD

#how to view generated PNG files
echo "To view the PNG files, go to the Jupyter file browser by selecting the jupyter logo to the top left of the terminal."
