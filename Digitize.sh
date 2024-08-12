#!/bin/bash
#SBATCH --time=6:00:00
#SBATCH --account=def-mdiamond
#SBATCH --mem=2G



# ------------------------------------------------------------------------------------------------
# Cosmic variables
cosmic=false
cosmic_dir=""
output_dir=${PATH_Digi_out}

# ------------------------------------------------------------------------------------------------
# Checking that options are valid and if cosmic input is being used
while getopts "c:o:" opt; do
	case $opt in 
		c)
			cosmic_dir="$OPTARG"
			cosmic=true
			echo "cosmic"
			;;
		o)
            output_dir="$OPTARG"
            echo "Setting output directory to $output_dir"
            ;;
		\?)
			echo "Invalid Option: ${OPTARG}"
			echo "Usage: <LHC_root_directory> -c <cosmic directory>"
			exit 1
			;;
		:)
			echo "-c requires argument: ${OPTARG}"
			echo "Usage: <LHC_root_directory> -c <cosmic directory>"
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

# ------------------------------------------------------------------------------------------------
# Checking and setting files/variables
if [ $# -ne 1 ]; then
	echo $#
	echo "Usage: -c <CosmicDataDirectory> <LHCDataDirectory>"
	exit 1
fi
# sourcing init.sh"
echo "sourcing init.sh"
source init.sh

# Change par_card.txt of digitizer to this one
cp par_cards/digitizer_par_card.txt ${digitizer_dir}/Digitizer/run/

# ------------------------------------------------------------------------------------------------
# Running digitizer
pushd ${digitizer_dir}

# Run the Digitizer
echo "Running Digitizer"
i=0
# Don't know exactly the name of the G4 output root file (dependent on date)
find "${1}" -type f -name "*.root" | while read -r file; do
	if [ ! -d ${output_dir}/$i ]; then
		mkdir ${output_dir}/$i -p
	fi

	if $cosmic; then
		echo "running cosmic"
		./digitizer -l $file -c $cosmic_dir  -o $output_dir/$i
	else 
		./digitizer -l $file  -o $output_dir/$i
	fi
	((i+=1))
done

popd


