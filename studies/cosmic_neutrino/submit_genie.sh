#!/bin/bash
#SBATCH --time=30:00:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-10
#SBATCH --mem=4G

#SBATCH --job-name=genie
#SBATCH --output=log-genie_%a.out

run_number=${SLURM_ARRAY_TASK_ID}
exposure=31536000
singularity exec /home/tomren/data/bin/release/singularity.sif  ./run_genie.sh $run_number $exposure