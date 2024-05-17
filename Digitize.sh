#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --mem=2G

# ------------------------------------------------------------------------------------------------
# Cosmic variables
cosmic=false
cosmic_dir=""

# ------------------------------------------------------------------------------------------------
# Checking that options are valid and if cosmic input is being used
while getopts "c:" opt; do
	case $opt in 
		c)
			cosmic_dir="$OPTARG"
			cosmic=true
			echo "cosmic"
			;;
		\?)
			echo "Invalid Option: ${OPTARG}"
			echo "Usage: <MacroDirectory> <DigitizerOutput> -c <cosmic directory>"
			exit 1
			;;
		:)
			echo "-c requires argument: ${OPTARG}"
			echo "Usage: <MacroDirectory> <DigitizerOutput> -c <cosmic directory>"
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

# ------------------------------------------------------------------------------------------------
# Checking and setting files/variables
if [ $# -ne 2 ]; then
	echo "Usage: <LHCDataDirectory> <OutputDirectory> -c <CosmicDataDirectory>"
	exit 1
fi
# sourcing init.sh"
echo "sourcing init.sh"
source init.sh

# Change par_card.txt of digitizer to this one
cp par_cards/par_card.txt ${digitizer_dir}/Digitizer/run/

# ------------------------------------------------------------------------------------------------
# Running digitizer
pushd ${digitizer_dir}

# Run the Digitizer
echo "Running Digitizer"
# Don't know exactly the name of the G4 output root file (dependent on date)
find "${1}" -type f -name "*.root" | while read -r file; do
	if $cosmic; then
		./digitizer -l $file -c $cosmic_dir  -o ${2}
	else 
		./digitizer -l $file  -o ${2}
	fi
done

popd


