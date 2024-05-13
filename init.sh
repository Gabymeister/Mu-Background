PATH_DATA="/project/rrg-mdiamond/data/MATHUSLA"


#------------------------------------------------------------------
# Dependencies
# PYTHIA is in Tom's home directory
# The rest is availabel from the preinstalled modules on cedar
export PYTHIA8=/project/def-mdiamond/tomren/mathusla/pythia8308
export PYTHIA8DATA=$PYTHIA8/share/Pythia8/xmldoc
PATH=$PATH:/project/def-mdiamond/tomren/mathusla/dlib-19.24/install
module load StdEnv/2020 gcc/9.3.0 qt/5.12.8 root/6.26.06  eigen/3.3.7 geant4/10.7.3 geant4-data/10.7.3

#------------------------------------------------------------------
# Get simulation, digitizer and tracker executables
pushd ..
if [ ! -f Mu-Simulation/simulation ]; then
	echo ""
	echo "Simulation executable not found, building the simulation/digitizer."
	git clone https://github.com/EdmondRen/Mu-Simulation.git
	cd Mu-Simulation
	./install --cmake
	./install_digitizer --cmake
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
simulation=`realpath Mu-Simulation/simulation`
digitizer=`realpath Mu-Simulation/digitizer`




#------------------------------------------------------------------
# Cosmic
PATH_COSMIC_in=$PATH_DATA/SimInput/cosmic
PATH_COSMIC_out=$PATH_DATA/SimOutput/cosmic
PATH_COSMIC_tmp=$PATH_DATA/temp/cosmic/
mkdir -p $PATH_COSMIC_in
mkdir -p $PATH_COSMIC_out
mkdir -p $PATH_COSMIC_tmp

export PATH_COSMIC_in=$PATH_COSMIC_in
export PATH_COSMIC_out=$PATH_COSMIC_out

# Build the code 
if [ ! -f cosmic/parma_cpp/cosmic_gen ]; then
    echo "Building the executable of PARMA CPP"
    pushd cosmic/parma_cpp
    g++ main-generator-mathusla.cpp subroutines.cpp -o cosmic_gen
    popd    
fi
# Set the output path of PARMA
ln -s  $PATH_COSMIC_tmp cosmic/parma_cpp/GeneOut
# ----------------------------------------------------------------



