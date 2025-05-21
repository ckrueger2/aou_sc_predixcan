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
    #git checkout 76a11b856f3cbab0b866033d518c201374a5594b
    if [ -f MetaXcan/software/conda_env.yaml ]; then
        conda env create -f MetaXcan/software/conda_env.yaml
        cd ..
    else
        # Create environment manually as fallback (version numbers may need to be changed with future updates)
        conda create -n imlabtools python=3.8 numpy pandas scipy -y
    fi
fi

#create imlabtools manually if needed (version numbers may need to be changed with future updates)
if ! conda env list | grep -q imlabtools; then
    echo "Failed to create imlabtools environment, creating manually"
    conda create -n imlabtools python=3.8 numpy pandas scipy h5py -y
fi
        
#download databases
#download expression models
if [ ! -f mashr_eqtl.tar ]; then
    echo "Downloading mashr_eqtl.tar..."
    wget https://zenodo.org/record/3518299/files/mashr_eqtl.tar -O mashr_eqtl.tar
    tar -xvf mashr_eqtl.tar
    rm mashr_eqtl.tar
fi

#download splicing models
if [ ! -f mashr_sqtl.tar ]; then
    echo "Downloading mashr_sqtl.tar..."
    wget https://zenodo.org/record/3518299/files/mashr_sqtl.tar -O mashr_sqtl.tar
    tar -xvf mashr_sqtl.tar
    rm mashr_sqtl.tar
fi

#download LD reference data for expression
if [ ! -f gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz ]; then
    echo "Downloading expression LD reference..."
    wget https://zenodo.org/record/3518299/files/gtex_v8_expression_mashr_snp_smultixcan_covariance.txt.gz
fi

download LD reference data for splicing
if [ ! -f gtex_v8_splicing_mashr_snp_smultixcan_covariance.txt.gz ]; then
    echo "Downloading splicing LD reference..."
    wget https://zenodo.org/record/3518299/files/gtex_v8_splicing_mashr_snp_smultixcan_covariance.txt.gz
fi

cd ..
