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
#download hail table
python "/home/jupyter/GWAS-TWAS-in-All-of-US-Cloud/pull_data.py" --phecode "$PHECODE" --pop "$POP"

#format hail tables
Rscript "/home/jupyter/GWAS-TWAS-in-All-of-US-Cloud/table_format.R" --phecode "$PHECODE" --pop "$POP"

#GWAS qqman
python "/home/jupyter/GWAS-TWAS-in-All-of-US-Cloud/qqman.py" --phecode "$PHECODE" --pop "$POP"

#locuszoomR
LOCUSZOOM_CMD="Rscript /home/jupyter/GWAS-TWAS-in-All-of-US-Cloud/locuszoom.R --phecode \"$PHECODE\" --pop \"$POP\""
if [[ ! -z "$RSID" ]]; then
    LOCUSZOOM_CMD="$LOCUSZOOM_CMD --rsid \"$RSID\""
fi
if [[ ! -z "$TOKEN" ]]; then
    LOCUSZOOM_CMD="$LOCUSZOOM_CMD --token \"$TOKEN\""
fi
eval $LOCUSZOOM_CMD

echo "To view the PNG files, go to the Jupyter file browser by selecting the jupyter logo to the top left of the terminal."
