# MicroHack-RosettaFold On Azure
Micro Hackthon of building Rosetta protein folding HPC cluster on Azure CycleCloud

License statement: All RoseTTFold related resource owner is RosettaCommons. Please refert to its license requirements. The [branch](https://github.com/Iwillsky/RoseTTAFold) used in this micro-hackthon which modified for HPC running environment is also under the compliance of its fork source.

## Scenarios
A research institute wants to run large amount protein folding computing jobs to find new folding structure.Due to the consideration of provision time and agility, traditional on-premises cluster will not be the option. They decide to leverage Azure Cloud to get computing resource promptly. Meanwhile, they need to accomplish this research in certain time and parallel method is essential.

## Objectives
This MicroHack is a walkthrough of creating an High Performance Computing (HPC) cluster on Azure and to run a typical HPC workload on it including the visualization of the results. The type of HPC workload manager we are going to use in this MicroHack is Slurm.

After completing this MicroHack you will:
· Know how to deploy a Slurm HPC cluster on Azure through Azure CycleCloud
· Run an HPC application on a Slurm HPC cluster

## Architecture diagram

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/ArchRosettaOnAzure.jpg)

## Pre-Requisites

· Read and know the license requirements of [RoseTTAFold](https://github.com/RosettaCommons/RoseTTAFold/blob/main/LICENSE) and its [weight data](https://files.ipd.uw.edu/pub/RoseTTAFold/Rosetta-DL_LICENSE.txt).  
· Apply for [PyRosetta License](https://els2.comotion.uw.edu/product/pyrosetta) and [download](http://www.pyrosetta.org/downloads) installation package file (suggest Python3.7 Linux version).   
· Have or [register a new Azure cloud account](https://www.microsoft.com/china/azure/index.html).  
· Create [SSH Key](https://docs.microsoft.com/en-us/azure/virtual-machines/ssh-keys-portal) and save the pem file.  
· Select the working Azure region (suggest Southeast Asia region). [Create Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#:~:text=1%20Sign%20in%20to%20the%20Azure%20portal.%202,newly%20created%20resource%20group%20to%20open%20it.%20) and [Create a Vnet](https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-portal).  
· Submit NCas_T4_v3 [quota increate request](https://docs.microsoft.com/en-us/azure/azure-portal/supportability/per-vm-quota-requests) of Azure T4 GPU Series VM. If need more performance, request the V100 series NCs_v3 quota instead.  
· This hands-on will charge cost. Here is a reference if use T4 VM in Southeast Asia region: less than $50 estimated 1 day accomplishment. Detailed pricing is [here](https://azure.microsoft.com/en-us/pricing/calculator/?service=virtual-machines). 

## Labs

· Task 1: CycleCloud installation 

· Task 2: Prepare RoseTTAFold VM Image 

· Task 3: Create a HPC cluster in CycleCloud

· Task 4: RoseTTAFold Dataset preparation

· Task 5: Run a RoseTTAFold sample   

### Task 1: CycleCloud installation

First step is to prepare CycleCloud Server through ARM template. Open Cloud Shell in Azure console and run below command to create a service principal. Remember the returned "appId", "password", "tenant" info in your notepad. 

```
az ad sp create-for-rbac --name RoseTTAFoldOnAzure --years 1 
```

Click the CycleCloud Server [template link](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCycleCloudCommunity%2Fcyclecloud_arm%2Fmaster%2Fazuredeploy.json) jump to custom deployment page in Azure console. Set region as Southeast Asia and resource group as rgCycleCloud. Provide the service principal info just created and setup a CycleCloud admin username & password for further login. Set storage account name as sacyclecloud and let other parameter as is. Click "Review+create" and then click "Create".

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/step_arm.png)

When resource is ready, go to the "cyclecloud" VM  overview page to find its DNS name. Open it at another web browser page, then login using admin username & password set previously. In first page of initial step, give a site name and then need agree the software license agreement at second page. In third page, User ID and Password is different with admin set in Step1.2, you may set them same for easily remember. Here SSH public key string is also required, which to be used to access VMs next.

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/step_usersetting.jpg)

At the upper right "cycleadmin" drop menu, click "My profile -> Edit profile" and provide your SSH public key string to save. It's a must-do step because this public key is used to scale VMs. Then use SSH login to this CycleCloud Server, and execute initialize command and press 'Enter' at each hint step. Then create a id_rsa file and provide your SSH private key string. Keep this SSH window open.

```
cyclecloud initialize
vi ~/.ssh/id_rsa   #provide private key string
chmod 400 ~/.ssh/id_rsa 
```

### Task 2: Prepare RoseTTAFold VM Image

In Azure console,  enter the VM creating page by Home->Create Resource->Virtual Machine. Set the basic configuration as:
	• Resource Group: rgCycleCloud
	• Virtual Machine name: vmRoseTTAFoldHPCImg
	• Region: Southeast Asia
	• Availability options: No infrastructure redundancy required
	• Image: CentOS-based 7.9 HPC Gen2 with GPU driver, CUDA and HPC tools pre-installed.(Click "See all images" and search this image in Marketplace)
	• Size: Standard NC16as_T4_v3  
	• Username: cycleadmin
	• SSH public key source: Use existing public key (if use SSH Keys in Azure)
	• SSH public key: <your SSH public key>
	• Virtual network: azurecyclecloud (or other existed VNet)
Click 'Review+Create' to check and then Create VM.
After this VM booted as Running status, we need one more step to enlarge the system disk size. Stop VM first with click option of reserve VM's public IP address. After status is as stopped, click VM Disk menu -> click system disk link -> 'Size + performance' to set the system disk size as 64G and performance tier P6 or higher. Wait till upper right pop-up info shows update accomplished then go back to Start the VM. VM status will change to Running several minutes later.
Using your SSH terminal to login to this VM and execute the next commands to install RoseTTAFold application, which include these steps:
	• Install Anaconda3. In process set the destination directory as /opt/anaconda3 and select yes when ask whether to init conda.
	• Download RoseTTAFold Github repo. It refers to a branch of RoseTTAFold repo which modified for adapting to HPC building.
	• Config two conda environments.
	• Install the PyRosetta4 component in folding conda environment. As a optional status check of PyRosetta4, enter Python command in folding env and then execute "import pyrosetta" and "pyrosetta.init()" with expectation of no error in output.

```
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
```

Strongly suggest to make a snapshot of this VM's OS disk before we go on. Then run this prepare command in SSH console and press 'y' to go.
```
sudo waagent -deprovision+user
```
When it's completed, go to Cloud Shell to run these commands:
```
az vm deallocate -n vmRoseTTAFoldHPCImg -g rgCycleCloud
az vm generalize -n vmRoseTTAFoldHPCImg -g rgCycleCloud
az image create -n imgRoseTTAhpc --source vmRoseTTAFoldHPCImg -g rgCycleCloud
```
After custom image created, go to Azure console page through Images -> imgRoseTTAhpc -> Overview. Find the 'RESOURCE ID' as form of '/subscriptions/xxx-xx-…xxxx/resourceGroups/rgCycleCloud/providers/Microsoft.Compute/images/imgRoseTTAhpc' and save it for further use. 

### Task 3: Create a HPC cluster in CycleCloud

In the CycleCloud UI, click add new cluster with Slurm scheduler type selected. Give a cluster name first, eg. clusRosetta1. Then config "required settings" page as below. Choose NC16as_T4_v3 as HPC VM type and set quantity in auto-scaling configuration. Network select 'azurecyclecloud-compute' subnet. Click "Next".

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/step_clusterparam.png)

Change CycleCloud default NFS disk size as 5000GB (training dataset will occupy 3T), which will be mounted at cluster startup. In "advanced settings" page, config the HPC OS type as "Custom image" and modify the image id as 'RESOURCE ID' at previous step. Left other option as is and click bottom right "Save" button.

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/step_clusteradv.png)

Click the "Start" to boot cluster. CycleCloud will then create VMs according configuration. After several minutes, a scheduler VM will be ready in list. Click this item and click "connect" button in below detail list to get the string like "cyclecloud connect scheduler -c clusRosetta1". Use this command in CycleCloud Server's SSH console to login to scheduler VM. 

### Task 4: RoseTTAFold Dataset preparation

Next is to prepare the datasets including weights and reference protein pdb database. In scheduler VM SSH console, run below command to load datasets into NFS volume mounted in cluster. We provide these dataset copy link at Azure Blob storage here to fasten the download speed. Your can also switch to original links as commented. Unzip operation will cost some time in hours. Suggest to unzip in multiple SSH windows with no interruption to assure the data integrity. Suggest to check the data size through 'du -sh <directory_name>' command after unzip operations.

```
cd /shared/home/cycleadmin
git clone https://github.com/Iwillsky/RoseTTAFold.git    #branch from RosettaCommons/RoseTTAFold modified for HPC env
cd RoseTTAFold
## wget https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz
wget https://asiahpcgbb.blob.core.windows.net/rosettaonazure/weights.tar.gz
tar -zxvf weights.tar.gz
 
## uniref30 [46G, unzip: 181G]
## wget http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz
wget https://asiahpcgbb.blob.core.windows.net/rosettaonazure/UniRef30_2020_06_hhsuite.tar.gz
mkdir -p UniRef30_2020_06
tar -zxvf UniRef30_2020_06_hhsuite.tar.gz -C ./UniRef30_2020_06
 
## BFD [272G, unzip: 1.8T]
## wget https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
wget https://asiahpcgbb.blob.core.windows.net/rosettaonazure/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
mkdir -p bfd
tar -zxvf bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz -C ./bfd
 
## structure templates (including *_a3m.ffdata, *_a3m.ffindex) [115G, unzip: 667GB]
## wget https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz
wget https://asiahpcgbb.blob.core.windows.net/rosettaonazure/pdb100_2021Mar03.tar.gz
tar -zxvf pdb100_2021Mar03.tar.gz
```

### Task 5: Run a RoseTTAFold sample

There is a job submission script in git repo named runjob.sh. Then we can submit a RoseTTAFold analysis job by SLURM sbatch command as below. 
```
sbatch runjob.sh
```
This sample job will cost some time est. at 30+ mins including steps of  MSA parameters generation, Hhsearch, prediction and modeling. Job's output can be checked in job<id>.out and logging files are at ~/log_<id>/ where you can find more progress info. AI training logging info can be found at ./log_<id>/folding.stdout. 
As a HPC cluster, you can submit multiple jobs. Slurm scheduler will allocate jobs to compute nodes in cluster. Multiple jobs allocation and status can be listed by 'squeue' command as below.

[cycleadmin@ip-0A00041F ~]$ squeue 
          JOBID PARTITION  NAME     USER     ST      TIME  NODES NODELIST(REASON)
           7       hpc   RosettaO  cycleadm  R       1:13      1 hpc-pg0-1
           8       hpc   RosettaO  cycleadm  R       0:08      1 hpc-pg0-2

If node is not sufficient, CycleCloud will boot new nodes for more accommodation. Meanwhile, CycleCloud will terminate nodes which no job running on it after a time window for cost saving. CycleCloud UI provide more detailed status info of cluster and nodes. GPU utilization reached near 100% in prediction steps and has idle time during running.

Successful running prompts as below. It will output 5 preferred protein pdb results at path of ~/model_<id>/ which named as model_x.pdb. 

[cycleadmin@ip-0A00041F ~]$ cat job9.out 
Running HHblits of JobId rjob204
Running PSIPRED of JobId rjob204
Running hhsearch of JobId rjob204
Predicting distance and orientations of JobId rjob204
Running parallel RosettaTR.py
Running DeepAccNet-msa of JobId rjob204
Picking final models of JobId rjob204
Final models saved in: /shared/home/cycleadmin/model_204
Done

### Lab Results

Below is the image of two pdb protein structure of pyrosetta and end2end results in [PyMOL tools](https://pymol.org/) UI. If you have many pdb results, suggest to mount NFS volume to a dedicate workstation for convenience.  

![image](https://github.com/Iwillsky/microHack-RosettaOnAzure/blob/main/images/pdb_result.jpg)

### Lab Teardown: 
If will not keep this enviroment, delete the resource group of 'rgCycleCloud' to tear down all the related resource directly.

## Appendix Links:

Science Rosetta article: [Accurate prediction of protein structures and interactions using a three-track neural network | Science (sciencemag.org)](https://science.sciencemag.org/content/early/2021/07/19/science.abj8754)

RoseTTAFold repo: [RosettaCommons/RoseTTAFold: This package contains deep learning models and related scripts for RoseTTAFold (github.com)](https://github.com/RosettaCommons/RoseTTAFold)

RoseTTAFold branch repo for HPC: [RoseTTAFold for HPC](https://github.com/Iwillsky/RoseTTAFold)







