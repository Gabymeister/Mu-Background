#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --array=1-10
#SBATCH --mem=2G

source init.sh

# one cosmic root file per lhc root file
echo "Generating LHC root file"
./run_lhc_muon.sh /home/owhgabri/scratch/MATHUSLA/MG5_aMC_v3_5_1 20000 5
echo "Generating cosmic root file"
./run_cosmic.sh -n 10000 -r ${SLURM_ARRAY_TASK_ID} 
echo "Digitizing LHC and Cosmic files"
./Digitize.sh ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID} -c ${PATH_COSMIC_OUT}/run_${SLURM_ARRAY_TASK_ID}
echo "removing G4 output directories"
rm -rf ${PATH_COSMIC_OUT}/run_${SLURM_ARRAY_TASK_ID}
rm -rf ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}


