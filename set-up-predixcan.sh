#! /bin/bash

# install and initialize miniconda
if [ ! -d ~/miniconda3 ]; then
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh
    source ~/miniconda3/bin/activate
    conda init --all
fi 

# clone repo and create environment
if [ ! -d MetaXcan ]; then
    git clone https://github.com/hakyimlab/MetaXcan
    git checkout 76a11b856f3cbab0b866033d518c201374a5594b
    conda env create -f MetaXcan/software/conda_env.yaml
fi

# download databases
if [ ! -d etql ]; then
    wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O mashr_eqtl.tar
    tar -xvpf mashr_eqtl.tar
    rm mashr_eqtl.tar
fi
