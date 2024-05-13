#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --array=30,40,50
#SBATCH --mem=2G

if [ $# -ne 2 ]; then
	echo "Usage: <MacroDirectory> <DigitizerOutput>"
	exit 1
fi

# G4Macros is the macro or a directory of macros
G4Macros=${1}
# DigiDataDir is the directory where the digitized root files are created
DigiDataDir=${2}

#echo "Running initsim"
# sourcing init.sh"
source init.sh

# Run Geant4
mkdir data/tmp_${SLURM_ARRAY_TASK_ID}

echo "Running Geant4"
if [ -d ${G4Macros} ]; then # This is a directory
	find "${G4Macros}" -type f -name "*.mac" | while read -r file; do
		${simulation} -q -s ${file} -o data/tmp_${SLURM_ARRAY_TASK_ID}
		# Example: Print the content of the file
		cat "$file"
	done
else 
	${simulation} -q -s ${G4Macros} -o data/tmp_${SLURM_ARRAY_TASK_ID}
fi

# Run the Digitizer
echo "Running Digitizer"
# Don't know exactly the name of the G4 output root file (dependent on date)
find "data/tmp_${SLURM_ARRAY_TASK_ID}" -type f -name "*.root" | while read -r file; do
  ${digitizer} $file ${DigiDataDir}
  rm -rf "data/tmp_${SLURM_ARRAY_TASK_ID}"
done


