#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --array=1-10
#SBATCH --mem=2G

source init.sh

./run_lhc_muon.sh /home/owhgabri/scratch/MATHUSLA/MG5_aMC_v3_5_1 20000
./run_cosmic.sh -n 1000 -r 1 -s Run -f
