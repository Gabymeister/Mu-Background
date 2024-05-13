#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --array=1-10
#SBATCH --mem=2G

# ${1} is the location of the madgraph executable.
# ${2} is the number of times you want to run madgraph (10k events each)
# ${3} is the minimum pT cutoff you want to apply (in MeV) (normally 20k)

if [ $# -ne 3 ]; then
	echo "Usage: $0 <MG5 TopDirectory> <RunNumber> <pT Cutoff>"
	echo "Note: MG5 TopDirectory should be the ABSOLUTE path"
	exit 1
fi

# MG5_Dir is where the madgraph TOP DIRECTORY is
MG5_Dir=${1}

# Scripts is the directory where the Base MadGraph Script is
Scripts="Mu-Simulation/VectorExtraction/MadGraphScripts"
# Extractor is the directory where the python extractor is
Extractor="Mu-Simulation/VectorExtraction/run_muon_extract.py"
# Combiner is the directory where the python extractor is
Combiner="Mu-Simulation/VectorExtraction/combine_muon_data.py"
# G4SimFiles is where the extracted muons and macros will be stored
G4SimFiles="data/G4SimFiles"
# G4DataDir is the directory where the Geant4 root files are created
G4DataDir="data/G4Output"

#MadGraphScripts is the directory where the created scripts will be stored
MadGraphScripts="${SLURM_TMPDIR}/MadGraphScripts"
# DataDir is the directory where the MadGraph folders are created
MGDataDir="${SLURM_TMPDIR}/MadGraphOutput"
#HepMCToText is where the text files are stored after being converted from Hepmc,
#but before being combined into one file.
HepMCToText="${SLURM_TMPDIR}/HepMCToText"

# Making MadGraph high I/O directories 
mkdir "${SLURM_TMPDIR}/MadGraphScripts"
mkdir "${SLURM_TMPDIR}/MadGraphOutput"
mkdir "${SLURM_TMPDIR}/HepMCToText"

if [ ! -d "${G4DataDir}" ]; then
	mkdir ${G4DataDir}
fi

if [ ! -d "${G4SimFiles}" ]; then
	mkdir ${G4SimFiles}
fi

# Sourcing init.sh
source init.sh

# Two identifiers: One is the MG5 set number, the other is the Job number
# Each set number corresponds to about 25 hours (check this)
NumSets=${2}
for (( c=0; c<NumSets; c++ )) # Generate NumSets*10000 MadGraph Events
do
  # Set the right version of pythia for madgraph
  echo "Exporting PYTHIA8"
  export PYTHIA8DATA="${MG5_Dir}/HEPTools/pythia8/share/Pythia8/xmldoc"

  # Create the MadGraph Scripts for each set of each job
  echo "Creating MadGraph Scripts"
  seedval=$((c + NumSets * SLURM_ARRAY_TASK_ID))
  cp "${Scripts}/test.txt" "${MadGraphScripts}/sm_muprod_wz_${SLURM_ARRAY_TASK_ID}_${c}.txt"
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
  python3 ${Extractor} "${HepMCDir}/Events/run_01/tag_1_pythia8_events.hepmc" "${HepMCToText}/bkg_muon_${SLURM_ARRAY_TASK_ID}_${c}.txt" ${3}

  # Delete the data folder
  echo "Removing data folder"
  rm -rf "${HepMCDir}"
done # Generated NumSets text files of 10000 muon events

 # Combine the Text Files into One/Create Geant4 scripts
echo "Combining Text Files"
python3 ${Combiner} "${G4SimFiles}" "${SLURM_ARRAY_TASK_ID}" "${NumSets}" "${HepMCToText}"
for (( c=0; c<NumSets; c++ ))
do
  rm "${HepMCToText}/bkg_muon_${SLURM_ARRAY_TASK_ID}_${c}.txt"
done

# Run the function initsim
echo "Running initsim"
export PYTHIA8=/project/def-mdiamond/tomren/mathusla/pythia8308
export PYTHIA8DATA=$PYTHIA8/share/Pythia8/xmldoc
PATH=$PATH:/project/def-mdiamond/tomren/mathusla/dlib-19.24/install
module load StdEnv/2020
module load qt/5.12.8
module load gcc/9.3.0
module load root/6.26.06
module load eigen/3.3.7
module load geant4/10.7.3
module load geant4-data/10.7.3
# Run Geant4
echo "Running Geant4"
${simulation} -q -s ${G4SimFiles}/bkg_muon_${SLURM_ARRAY_TASK_ID}.mac -o ${G4DataDir}/bkg_muon_${SLURM_ARRAY_TASK_ID}
