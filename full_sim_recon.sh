#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-1000
#SBATCH --mem=2G
#SBATCH --job-name=mu-fullsim
#SBATCH --output=scripts/slurm_log/log-mu-fullsim-recon_%a.out

source init.sh

SLURM_ARRAY_TASK_ID=1

# one cosmic root file per lhc root file
echo "Generating LHC root file"
#./run_lhc_muon.sh 308
echo "Generating cosmic root file"
#./run_cosmic.sh -n 10000 -r ${SLURM_ARRAY_TASK_ID} -f -s Run

echo "Digitizing LHC and Cosmic files"
./Digitize.sh -c ${PATH_COSMIC_out}/run_${SLURM_ARRAY_TASK_ID} -o $PATH_Digi_out/$SLURM_ARRAY_TASK_ID ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}

process_all $PATH_Digi_out/$SLURM_ARRAY_TASK_ID/0/stat0.root $PATH_Digi_out/$SLURM_ARRAY_TASK_ID/0


touch scripts/slurm_log/job_${SLURM_ARRAY_TASK_ID}_finished

#echo "removing G4 output directories"
#rm -rf ${PATH_COSMIC_out}/run_${SLURM_ARRAY_TASK_ID}
#rm -rf ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}


