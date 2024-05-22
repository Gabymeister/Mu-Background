PATH_DATA="/project/rrg-mdiamond/data/MATHUSLA"

#------------------------------------------------------------------
# Dependencies
# MG5, PYTHIA and dlib are manually installed
# The rest is available from the preinstalled modules on cedar
export MG5_Dir=${PATH_DATA}/bin/MG5_aMC_v3_5_4
export MG5_bin=${MG5_Dir}/bin/mg5_aMC
export PYTHIA8=${MG5_Dir}/HEPTools/pythia8
export PYTHIA8DATA=${MG5_Dir}/HEPTools/pythia8/share/Pythia8/xmldoc
PATH=$PATH:${PATH_DATA}/bin/dlib-19.24/install
module load StdEnv/2020 gcc/9.3.0 qt/5.12.8 root/6.26.06  eigen/3.3.7 geant4/10.7.3 geant4-data/10.7.3

#------------------------------------------------------------------
# Get simulation, digitizer and tracker executables
pushd ..
if [ ! -f Mu-Simulation/simulation ]; then
	echo ""
	echo "Simulation executable not found, building the simulation/digitizer."
	git clone https://github.com/Gabymeister/Mu-Simulation.git
	cd Mu-Simulation
	./install --cmake
	./install_digitizer --cmake
	cd ..
fi
if ! command -v pytracker &> /dev/null; then
	echo ""
	echo "Tracker executable not found. Installing it in user directory in editing mode."
	git clone https://github.com/EdmondRen/pyTracker.git
	cd pyTracker
	pip install -e . --user
fi
popd
# Now we have the simulation and digitizer. Make an alias for them
# The tracker can be run directly with command pytracker
export simulation_dir=`realpath ../Mu-Simulation`
export digitizer_dir=`realpath ../Mu-Simulation`


#------------------------------------------------------------------
# Cosmic
# Make directories for input, output and temporary files
PATH_COSMIC_in=${PATH_DATA}/SimInput/cosmic
PATH_COSMIC_out=${PATH_DATA}/SimOutput/cosmic
PATH_COSMIC_tmp=${PATH_DATA}/temp/cosmic/
mkdir -p $PATH_COSMIC_in
mkdir -p $PATH_COSMIC_out
mkdir -p $PATH_COSMIC_tmp
export PATH_COSMIC_in=$PATH_COSMIC_in
export PATH_COSMIC_out=$PATH_COSMIC_out
export PATH_COSMIC_tmp=$PATH_COSMIC_tmp

# Build the code 
if [ ! -f cosmic/parma_cpp/cosmic_gen ]; then
    echo "Building the executable of PARMA CPP"
    pushd cosmic/parma_cpp
    g++ main-generator-mathusla.cpp subroutines.cpp -o cosmic_gen
    popd    
fi
# Set the output path of PARMA
ln -sf  $PATH_COSMIC_tmp cosmic/parma_cpp/GeneOut

# ----------------------------------------------------------------
# LHC (MadGraph)
# Make directories for input, output and temporary files
PATH_MG5_in=${PATH_DATA}/SimInput/MG5 # Location of scripts for MadGraph
PATH_MG5_out=${PATH_DATA}/SimOutput/MG5 #Location of generated text files for G4
PATH_MG5_tmp=${PATH_DATA}/temp/MG5/
mkdir -p $PATH_MG5_in
mkdir -p $PATH_MG5_out
mkdir -p $PATH_MG5_tmp
export PATH_MG5_in=$PATH_MG5_in
export PATH_MG5_out=$PATH_MG5_out
export PATH_MG5_tmp=$PATH_MG5_tmp


# ----------------------------------------------------------------
# Digitizer


PATH_Digi_out=${PATH_DATA}/DigiOutput # Location of the digitized output

mkdir -p $PATH_Digi_out

export PATH_Digi_out=$PATH_Digi_out

