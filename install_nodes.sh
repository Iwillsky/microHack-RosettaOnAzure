#!/bin/bash

### Boot a VM using CentOS-based HPC 7.9 Gen2
### Resize OS disk(Stop VM; Set OS disk at least 64G; start VM)
### SSH login 

## Install anaconda 
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
chmod +x Anaconda3-2021.05-Linux-x86_64.sh
sudo bash ./Anaconda3-2021.05-Linux-x86_64.sh
# read license with blank to next page
# set the destination dir as /opt/anaconda3
# select 'yes' when ask if need conda init
cat <<EOF | sudo tee -a /etc/profile
export PATH=\$PATH:/opt/anaconda3/bin
EOF
source /etc/profile

## Get repo and setup conda env 
cd /opt
sudo su
conda deactivate    #back to VM shell
git clone https://github.com/Iwillsky/RoseTTAFold.git    #branch from RosettaCommons/RoseTTAFold modified for HPC env
cd RoseTTAFold
conda env create -f RoseTTAFold-linux.yml
conda env create -f folding-linux.yml
conda env list
./install_dependencies.sh

## Install pyrosetta in folding env
conda init bash
source ~/.bashrc
conda activate folding
# original download link: https://www.pyrosetta.org/downloads 
# Register first. Below is a copy, while download means obey the license requirements at https://els2.comotion.uw.edu/product/pyrosetta
wget https://asiahpcgbb.blob.core.windows.net/rosettaonazure/PyRosetta4.Release.python37.linux.release-289.tar.bz2
tar -vjxf PyRosetta4.Release.python37.linux.release-289.tar.bz2
cd PyRosetta4.Release.python37.linux.release-289/setup
python setup.py install
# [Optional] verify the pyrosetta lib
# python   #then input two lines:  <<<import pyrosetta;   <<<pyrosetta.init()
conda deactivate    #back to conda (base)
conda deactivate    #back to VM shell

## Suggest to create a snapshot before next step
# sudo waagent -deprovision+user

## In Azure Cloud Shell, prepare VM image and get RESOURCE ID
# az vm deallocate -n vmRoseTTAFoldHPCImg -g rgCycleCloud
# az vm generalize -n vmRoseTTAFoldHPCImg -g rgCycleCloud
# az image create -n imgRoseTTAhpc --source vmRoseTTAFoldHPCImg -g rgCycleCloud
