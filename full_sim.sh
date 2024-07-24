#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-100
#SBATCH --mem=2G
#SBATCH --job-name=mu-fullsim
#SBATCH --output=scripts/slurm_log/log-mu-fullsim_%a.out

source init.sh

# one cosmic root file per lhc root file
echo "Generating LHC root file"
./run_lhc_muon.sh 15
echo "Generating cosmic root file"
./run_cosmic.sh -n 1000 -r ${SLURM_ARRAY_TASK_ID} -f -s Run

echo "Digitizing LHC and Cosmic files"
if [ ! -d digi_out/${SLURM_ARRAY_TASK_ID} ]; then
	mkdir digi_out/${SLURM_ARRAY_TASK_ID}
fi
./Digitize.sh -c ${PATH_COSMIC_out}/run_${SLURM_ARRAY_TASK_ID} ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}

#echo "removing G4 output directories"
#rm -rf ${PATH_COSMIC_out}/run_${SLURM_ARRAY_TASK_ID}
#rm -rf ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}


