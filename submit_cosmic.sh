#!/bin/bash
#SBATCH --time=1:40:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-100
#SBATCH --mem=2G

#SBATCH --job-name=mu-cosmic
#SBATCH --output=scripts/slurm_log/log-mu-cosmic_%a.out





#############################################
## HELP:
## Change the --array option above to the number of job you would like to run
#     --array=START-END, for example, 1-2 will run two jobs with SLURM_ARRAY_TASK_ID = 1 and 2
## Run the following command to submit jobs:
# --output=${PATH_COSMIC_out}/log-mu-cosmic_%a.out
#     sbatch  submit_cosmic.sh
## Check the code below, comment out the ones that you do not need
#############################################




# Option 1: Run all particles except 2-28
# argument n sets the number of events. n=100_000 takes ~50-100 minutes
# argument p sets the particle type. Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

# ./run_cosmic.sh  -n 10000 -r ${SLURM_ARRAY_TASK_ID} -s Run -d -f -c




# Option 2: Run single particle
# argument n sets the number of PARMA events. n=100_000 generates about ~43k events in the detector while ~20k are good tracks, and takes ~50-100 minutes
# argument p sets the particle type. Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

# In order to get enough events for all channels, 100e3/6 * 500=~8M muon events needed. 
#  --> 8/0.2 = 40 M PARMA events. 400k events per run--> 100 runs
# Storage: 20MB (Sim+Digi+Recon) for ~2k of (recorded) events, --> 2 kB per event, 16 GB for 8M of events

./run_cosmic.sh  -n 400000 -r ${SLURM_ARRAY_TASK_ID} -s Run -p 30 -d -f -c