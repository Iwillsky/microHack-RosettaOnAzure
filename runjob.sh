#!/bin/bash
#SBATCH -o job%j.out
#SBATCH --job-name=RosettaOnAzure
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --gres=gpu:1
JOBID=$SLURM_ARRAY_JOB_ID
WORKDIR=/shared/home/cycleadmin/RoseTTAFold

$WORKDIR/run_pyrosetta_ver.sh $WORKDIR/input.fa $WORKDIR $JOBID 16 96
#$WORKDIR/run_e2e_ver.sh $WORKDIR/input.fa $WORKDIR $JOBID 16 96