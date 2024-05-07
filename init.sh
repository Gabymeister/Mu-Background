PATH_DATA="/project/rrg-mdiamond/data/MATHUSLA"


#------------------------------------------------------------------
# Cosmic
# setup
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



