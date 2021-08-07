#!/bin/bash

### Boot a VM using CentOS-based HPC 7.9 Gen2
### Resize OS disk(Stop VM; Set sys disk as 64G; start VM)
### SSH login

## install anaconda 
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
chmod +x Anaconda3-2021.05-Linux-x86_64.sh
sudo bash ./Anaconda3-2021.05-Linux-x86_64.sh
#read license with blank to next page
#set the destination dir as /opt/anaconda3
#select 'yes' when ask if need conda init
cat <<EOF | sudo tee -a /etc/profile
export PATH=\$PATH:/opt/anaconda3/bin
EOF
source /etc/profile

## Get repo and build 
cd /opt/anaconda3
sudo su
git clone https://github.com/RosettaCommons/RoseTTAFold.git
cd RoseTTAFold
conda env create -f RoseTTAFold-linux.yml
conda env create -f folding-linux.yml
conda env list
./install_dependencies.sh

conda init bash
source /home/azureuser/.bashrc
conda activate folding
wget https://proteinfoldonazure.blob.core.windows.net/data/PyRosetta4.Release.python37.linux.release-289.tar.bz2
tar -vjxf PyRosetta4.Release.python37.linux.release-289.tar.bz2 
cd PyRosetta4.Release.python37.linux.release-289/setup
python setup.py install
#verify the pyrosetta lib
python   #then input two lines:  <<<import pyrosetta;   <<<pyrosetta.init()
conda deactivate   #back to conda (base)
conda deactivate    #back to VM shell

