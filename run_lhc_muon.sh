# ${1} is the minimum pT cutoff you want to apply (in MeV) (normally 20k)
# ${2} is the number of MG5 events to run*10 thousand (i.e. 5 -> 50000 events)

# NOTE: THIS SCRIPT MUST BE RUN WITHIN A SLURM JOB. MG5 Output is too large otherwise

# Usage
if [ $# -ne 2 ]; then
	echo "Usage: $0  <pT Cutoff (MeV)> <RUN_NUMBER*10k>" # Print help message if number of arguments is more than 2
	exit 1
fi
pTcut=${1}
NumSets=${2}


# ---------------------------------------------------------------------------------------
# PATHS TO EXECUTABLES
# Scripts is the directory where the Base MadGraph Script is
Scripts=${simulation_dir}/VectorExtraction/MadGraphScripts
# Extractor is the directory where the python extractor is
Extractor=${simulation_dir}/VectorExtraction/run_muon_extract.py
# Combiner is the directory where the python extractor is
Combiner=${simulation_dir}/VectorExtraction/combine_muon_data.py

# ---------------------------------------------------------------------------------------
# TEMPORARY DIRECTORIES FOR MADGRAPH
if [ -z "$SLURM_TMPDIR" ]; then 
  echo "No SLURM_TMPDIR, running locally"
  SLURM_TMPDIR=$PATH_MG5_in
  SLURM_ARRAY_TASK_ID=0
fi
#MadGraphScripts is the directory where the created scripts will be stored
MadGraphScripts="${SLURM_TMPDIR}/MadGraphScripts"
# DataDir is the directory where the MadGraph folders are created
MGDataDir="${SLURM_TMPDIR}/MadGraphOutput"
#HepMCToText is where the text files are stored after being converted from Hepmc,
#but before being combined into one file.
HepMCToText="${SLURM_TMPDIR}/HepMCToText"
# Making MadGraph high I/O directories 
mkdir -p $MadGraphScripts
mkdir -p $MGDataDir
mkdir -p $HepMCToText


# ---------------------------------------------------------------------------------------
# Running MadGraph
# Two identifiers: One is the MG5 set number, the other is the Job number
for (( c=0; c<NumSets; c++ )) # Generate NumSets*10000 MadGraph Events
do

  # Create the MadGraph Scripts for each set of each job
  echo "Creating MadGraph Scripts"
  seedval=$((c + NumSets * SLURM_ARRAY_TASK_ID))
  cp "${Scripts}/sm_muprod_wz.txt" "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"
  sed -i "14s/.*/set iseed = ${seedval}/" "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"
  sed -i "5s|.*|output ${MGDataDir}/proc_sm_muprod_wz_matched_${SLURM_ARRAY_TASK_ID}_${c}|" "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"
  sed -i "6s|.*|launch ${MGDataDir}/proc_sm_muprod_wz_matched_${SLURM_ARRAY_TASK_ID}_${c}|" "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"

  # Run Madgraph
  echo "Running MadGraph"
  ${MG5_Dir}/bin/mg5_aMC "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"
  HepMCDir="${MGDataDir}/proc_sm_muprod_wz_matched_${SLURM_ARRAY_TASK_ID}_${c}"
  # Unzip the data
  gzip -d "${HepMCDir}/Events/run_01/tag_1_pythia8_events.hepmc.gz"

  # Run the extractor
  echo "Extracting Muons"
  python3 ${Extractor} "${HepMCDir}/Events/run_01/tag_1_pythia8_events.hepmc" "${HepMCToText}/bkg_muon_${SLURM_ARRAY_TASK_ID}_${c}.txt" $pTcut

  # Delete the data folder
  echo "Removing data folder"
  rm -rf "${HepMCDir}"
done # Generated NumSets text files of 10000 muon events

# ---------------------------------------------------------------------------------------
 # Combine the Text Files into One/Create Geant4 scripts
echo "Combining Text Files"
python3 ${Combiner} "${PATH_MG5_in}" "${SLURM_ARRAY_TASK_ID}" "${NumSets}" "${HepMCToText}"
for (( c=0; c<NumSets; c++ ))
do
  rm "${HepMCToText}/bkg_muon_${SLURM_ARRAY_TASK_ID}_${c}.txt"
done

# ---------------------------------------------------------------------------------------
# Run Geant4
echo "Running Geant4"
echo "simulation directory: ${simulation_dir}"
pushd ${simulation_dir}
./simulation -s ${PATH_MG5_in}/bkg_muon_${SLURM_ARRAY_TASK_ID}.mac -o ${PATH_MG5_out}/bkg_muon_${SLURM_ARRAY_TASK_ID}
popd


# Clean up the text file
rm -rf $SLURM_TMPDIR
