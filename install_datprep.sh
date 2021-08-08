#!/bin/bash

cd /shared/home/cycleadmin
git clone https://github.com/Iwillsky/RoseTTAFold.git    #branch from RosettaCommons/RoseTTAFold modified for HPC env
cd RoseTTAFold

## wget https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz
wget https://proteinfoldonazure.blob.core.windows.net/data/weights.tar.gz
tar -zxvf weights.tar.gz
 
## uniref30 [46G, unzip: 181G]
## wget http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz
wget https://proteinfoldonazure.blob.core.windows.net/data/UniRef30_2020_06_hhsuite.tar.gz
mkdir -p UniRef30_2020_06
tar -zxvf UniRef30_2020_06_hhsuite.tar.gz -C ./UniRef30_2020_06
 
## BFD [272G, unzip: 1.8T]
## wget https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
wget https://proteinfoldonazure.blob.core.windows.net/data/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
mkdir -p bfd
tar -zxvf bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz -C ./bfd
 
## structure templates (including *_a3m.ffdata, *_a3m.ffindex) [115G, unzip: 667GB]
## wget https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz
wget https://proteinfoldonazure.blob.core.windows.net/data/pdb100_2021Mar03.tar.gz
tar -zxvf pdb100_2021Mar03.tar.gz
