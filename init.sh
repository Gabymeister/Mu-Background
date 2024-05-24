#------------------------------------------------------------
# CHANGE THE RUN NAME
PATH_MATHUSLA="/project/rrg-mdiamond/data/MATHUSLA/"
RUN_NAME="run-2024-05-cosmic-setup" # RUN Name. ALWAYS START WITH 'run-YYYY-MM-'

# * PATH_MATHUSLA sets the path to the MATHUSLA folder
# * RUN_NAME sets the run name
# For each run, a new folder will be created under the MATHUSLA folder
# The run folder structrues as following:
#
# ${PATH_MATHUSLA}
# 	|--${RUN_NAME}
# 		|--SimInput
# 		|	|-- cosmic
# 		|	|		|-- run_0
# 		|	|		|-- run_1
# 		|	|		`-- run_2...
# 		|	`-- MG5
# 		|		|-- run_0
# 		|		|-- run_1
# 		|		`-- run_2...
# 		|--SimOutput
# 		|	|-- cosmic
# 		|	`-- MG5
# 		|--DigiOutput
# 		|	`-- ....  
# 		`--config
#------------------------------------------------------------


PATH_DATA=${PATH_MATHUSLA}/simulation/$RUN_NAME
PATH_DATA_config=${PATH_MATHUSLA}/simulation/$RUN_NAME/config
export PATH_DATA=$PATH_DATA
export PATH_DATA_config=$PATH_DATA_config
mkdir -p $PATH_DATA
mkdir -p $PATH_DATA_config



#------------------------------------------------------------------
# Dependencies
# MG5, PYTHIA and dlib are manually installed
# The rest is available from the preinstalled modules on cedar
export MG5_Dir=${PATH_MATHUSLA}/bin/MG5_aMC_v3_5_4
export MG5_bin=${MG5_Dir}/bin/mg5_aMC
export PYTHIA8=${MG5_Dir}/HEPTools/pythia8
export PYTHIA8DATA=${MG5_Dir}/HEPTools/pythia8/share/Pythia8/xmldoc
PATH=$PATH:${PATH_MATHUSLA}/bin/dlib-19.24/install
module load StdEnv/2020 gcc/9.3.0 qt/5.12.8 root/6.26.06  eigen/3.3.7 geant4/10.7.3 geant4-data/10.7.3

#------------------------------------------------------------------
# Get simulation, digitizer and tracker executables
if [ ! -f ../Mu-Simulation/simulation ]; then
	pushd ..
	echo ""
	echo "Simulation executable not found, building the simulation/digitizer."
	git clone https://github.com/Gabymeister/Mu-Simulation.git
	cd Mu-Simulation
	./install --cmake
	./install_digitizer --cmake
	cd ..
	popd	
fi
if ! command -v pytracker &> /dev/null; then
	pushd ..
	echo ""
	echo "Tracker executable not found. Installing it in user directory in editing mode."
	git clone https://github.com/EdmondRen/pyTracker.git
	cd pyTracker
	pip install -e . --user
	popd
fi

# Now we have the simulation and digitizer. Make an alias for them
# The tracker can be run directly with command pytracker
export simulation_dir=`realpath ../Mu-Simulation`
export digitizer_dir=`realpath ../Mu-Simulation`



#------------------------------------------------------------------
# Cosmic
# Make directories for input, output and temporary files
PATH_COSMIC_in=${PATH_DATA}/SimInput/cosmic
PATH_COSMIC_out=${PATH_DATA}/SimOutput/cosmic
mkdir -p $PATH_COSMIC_in
mkdir -p $PATH_COSMIC_out
export PATH_COSMIC_in=$PATH_COSMIC_in
export PATH_COSMIC_out=$PATH_COSMIC_out

# Build the code 
# if [ ! -f cosmic/parma_cpp/cosmic_gen ]; then
echo "Building the executable of PARMA CPP"
cd cosmic/parma_cpp
g++ main-generator-mathusla.cpp subroutines.cpp -o cosmic_gen
cd ../..    
# fi
# Set the output path of PARMA
ln -sfn  $PATH_COSMIC_in cosmic/parma_cpp/GeneOut

# ----------------------------------------------------------------
# LHC (MadGraph)
# Make directories for input, output and temporary files
PATH_MG5_in=${PATH_DATA}/SimInput/MG5 # Location of scripts for MadGraph
PATH_MG5_out=${PATH_DATA}/SimOutput/MG5 #Location of generated text files for G4
mkdir -p $PATH_MG5_in
mkdir -p $PATH_MG5_out
export PATH_MG5_in=$PATH_MG5_in
export PATH_MG5_out=$PATH_MG5_out


# ----------------------------------------------------------------
# Digitizer
PATH_Digi_out=${PATH_DATA}/DigiOutput # Location of the digitized output
mkdir -p $PATH_Digi_out
export PATH_Digi_out=$PATH_Digi_out




echo "Environment setup finished"
echo ""
echo "Run: ${RUN_NAME}"
echo "Results saved in ${PATH_DATA}" 


