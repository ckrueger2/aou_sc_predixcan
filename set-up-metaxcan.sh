#! /bin/bash

# clone metaxcan repo
git clone https://github.com/hakyimlab/MetaXcan.git

# create requisite conda virtual environment
cd MetaXcan/software
conda env create -f conda_env.yaml
conda activate imlabtools

# get transcriptome model databases and SNP covariance matrices
mkdir allofus_test
cd allofus_test
wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O mashr_eqtl.tar
tar -xvpf mashr_eqtl.tar
rm mashr_eqtl.tar