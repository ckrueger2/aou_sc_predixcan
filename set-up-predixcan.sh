#! /bin/bash

# install miniconda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# initialize conda
source ~/miniconda3/bin/activate
conda init --all

# clone repo
git clone https://github.com/hakyimlab/MetaXcan

# create environment
conda env create -f MetaXcan/software/conda_env.yaml

# download databases
wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O mashr_eqtl.tar
tar -xvpf mashr_eqtl.tar
rm mashr_eqtl.tar