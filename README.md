# microHack-RosettaOnAzure
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
![image]()

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

![image]()

When resource is ready, go to the "cyclecloud" VM  overview page to find its DNS name. Open it at another web browser page, then login using admin username & password set previously. In first page of initial step, give a site name and then need agree the software license agreement at second page. In third page, User ID and Password is different with admin set in Step1.2, you may set them same for easily remember. Here SSH public key string is also required, which to be used to access VMs next.

![image]()

At the upper right "cycleadmin" drop menu, click "My profile -> Edit profile" and provide your SSH public key string to save. It's a must-do step because this public key is used to scale VMs. Then use SSH login to this CycleCloud Server, and execute initialize command and press 'Enter' at each hint step. Then create a id_rsa file and provide your SSH private key string. Keep this SSH window open.

```
cyclecloud initialize
vi ~/.ssh/id_rsa   #provide private key string
chmod 400 ~/.ssh/id_rsa 
```

### Task 2: Prepare RoseTTAFold VM Image


### Task 3: Create a HPC cluster in CycleCloud


### Task 4: RoseTTAFold Dataset preparation


### Task 5: Run a RoseTTAFold sample


### Results


### Teardown: 


## Appendix Links:



