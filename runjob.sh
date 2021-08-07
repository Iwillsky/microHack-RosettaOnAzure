#!/bin/bash
#SBATCH -o job%j.out
#SBATCH --job-name=Fold
#SBATCH --nodes=1       
## #SBATCH --gres=gpu:1

/opt/RoseTTAFold/run_pyrosetta_ver.sh /share/home/cycleadmin/input.fa /share/home/cycleadmin/