#!/bin/bash
#install and initialize miniconda
if [ ! -d ~/miniconda3 ]; then
    mkdir -p ~/miniconda3
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh
    eval "$(~/miniconda3/bin/conda shell.bash hook)"
    conda init bash
fi 
#clone repo and create environment
if [ ! -d MetaXcan ]; then
    git clone https://github.com/hakyimlab/MetaXcan
    cd MetaXcan
    #git checkout 76a11b856f3cbab0b866033d518c201374a5594b
    if [ -f MetaXcan/software/conda_env.yaml ]; then
        conda env create -f MetaXcan/software/conda_env.yaml
        cd ..
    else
        # Create environment manually as fallback - ADDED MISSING PACKAGES HERE
        conda create -n imlabtools python=3.8 numpy pandas scipy h5py sqlalchemy patsy statsmodels -y
    fi
    cd ..
fi
#create imlabtools manually if needed - ADDED MISSING PACKAGES HERE TOO
if ! conda env list | grep -q imlabtools; then
    echo "Failed to create imlabtools environment, creating manually"
    conda create -n imlabtools python=3.8 numpy pandas scipy h5py sqlalchemy patsy statsmodels -y
fi

# ADD THESE TWO LINES TO INSTALL THE BIO PACKAGES VIA PIP
source ~/miniconda3/bin/activate
conda activate imlabtools
pip install bgen-reader>=3.0.3 cyvcf2>=0.8.0
conda deactivate
