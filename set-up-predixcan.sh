#! /bin/bash

# install and initialize miniconda
if [ ! -d ~/miniconda3 ]; then
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh
    eval "$(~/miniconda3/bin/conda shell.bash hook)"
    conda init bash
fi 

# clone repo and create environment
if [ ! -d MetaXcan ]; then
    git clone https://github.com/hakyimlab/MetaXcan
    cd MetaXcan
    git checkout 76a11b856f3cbab0b866033d518c201374a5594b
    cd ..
    if [ -f MetaXcan/software/conda_env.yaml ]; then
        conda env create -f MetaXcan/software/conda_env.yaml
    else
        # Create environment manually as fallback (version numbers may need to be changed with future updates)
        conda create -n imlabtools python=3.8 numpy=1.19 pandas scipy -y
    fi
fi

#create imlabtools manually if needed (version numbers may need to be changed with future updates)
if ! conda env list | grep -q imlabtools; then
    echo "Failed to create imlabtools environment, creating manually"
    conda create -n imlabtools python=3.8 numpy=1.9 pandas scipy h5py -y
fi
        
# download databases
if [ ! -d eqtl ]; then
    wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar?download=1 -O mashr_eqtl.tar
    tar -xvpf mashr_eqtl.tar
    rm mashr_eqtl.tar
fi
