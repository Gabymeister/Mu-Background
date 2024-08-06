#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-100
#SBATCH --mem=4G

#SBATCH --job-name=mu-cosmic
#SBATCH --output=scripts/slurm_log/log-mu-cosmic_%a.out

./simulation -q -s ${PATH_MG5_in}/bkg_muon_${SLURM_ARRAY_TASK_ID}.mac -o ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}



../../Mu-Simulation/simulation  -q -o  /project/6049244/data/MATHUSLA/simulation/run-2024-07-17 -s geant_particle_gun.mac pid 2212 p_mag 10 count 1000