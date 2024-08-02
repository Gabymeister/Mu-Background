#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1-10
#SBATCH --mem=2G
#SBATCH --constraint=cascade

#SBATCH --job-name=genie-g4
#SBATCH --output=/project/6049244/data/MATHUSLA/simulation/run-2024-07-cosmic-neutrino/log/log-mu-cosmic_%a.out

run=$SLURM_ARRAY_TASK_ID
# run=1


dir_repo="/project/6035200/tomren/jupyter/Background_gen-MATHUSLA40/Mu-Background"
dir_exe="/project/6035200/tomren/jupyter/Background_gen-MATHUSLA40/Mu-Simulation"
dir_out="/project/6049244/data/MATHUSLA/simulation/run-2024-07-cosmic-neutrino"

dir_digi=${dir_out}/DigiOutput/run_$run
dir_sim=${dir_out}/SimOutput/run_$run
mkdir -p ${dir_out}/SimOutput/run_$run
mkdir -p ${dir_out}/DigiOutput/run_$run



pushd ${dir_exe}

echo
echo "Running digitizer on cosmic sim result..."
echo
./simulation -q  -o ${dir_out}/SimOutput/run_$run  -s $dir_out/genie/filereader_gntp.$run.gtrac.mac


# --------------------------------------------------------------------
# Run digitizer and tracker
echo
echo "Running digitizer on cosmic sim result..."
echo

i=0
find $dir_sim -type f -name "run0.root" | while read -r file; do
    echo "processing file ${file}"
    mkdir -p ${dir_digi}/$i
    # digitizer
    ./digitizer -l $file  -o $dir_digi/$i
    # tracker
    pytracker $dir_digi/$i/stat0.root $dir_digi/$i  --config $dir_repo/par_cards/tracker_config.py --overwrite
    ((i+=1))
done    

popd
