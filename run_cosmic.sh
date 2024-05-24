# Usage
# ./run_cosmic.sh [-n NUMBER_OF_EVENTS (default is 10000)] [-r RUN_NUMBER (default is 1)] [-s SUBMIT_JOB ({True, False, Run}, defulat is False)] [-p PARTICLE]
# Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

NEVENTS=10000
RUN=1
SUBMIT="False" # {True, False, Run}
PARTICLES=(0 1 29 30 31 32 33)
PARTICLES_USER=
OVERWRITE=
DIGITIZE=
CLEAN_OUTPUT=

usage() { 
    echo "Usage: $0 [-n NUMBER_OF_EVENTS] [-r RUN_NUMBER] [-s SUBMIT_JOB {True, False, Run}] [-p PARTICLE] [-h] [-f] [-d] [-c]" 1>&2; 
    echo "Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)"; 
    echo " [-f] force to overwrite existing output directory";
    echo " [-d] run digitizer"
    echo " [-c] cleans the output directory"
    exit 1; }
while getopts n:r:s:p:hfdc flag
do
    case "${flag}" in
        n) NEVENTS=${OPTARG};;
        r) RUN=${OPTARG};;
        s) SUBMIT=${OPTARG};;
        p) PARTICLES_USER=${OPTARG};;
        f) OVERWRITE=1;;
        d) DIGITIZE=1;;
        c) CLEAN_OUTPUT=1;;
        h) usage;;
    esac
done

# --------------------------------------------------------------------
# Run the cosmic sim (PARMA + G4)
# temporarily go into cosmic/parcpp folder
pushd cosmic/parma_cpp
# Check if PARMA output directory exists
if ([ -d "GeneOut/run_${RUN}" ] && [ -z "${OVERWRITE}" ]); then
    echo " [Error] Directory exists! Use -f option to overwrite. Exiting..."
    exit 1
elif [ ! -z "${OVERWRITE}" ]; then
    echo "Directory exists! Deleting existing file..."
    \rm GeneOut/run_$RUN/* -rf
fi
mkdir -p GeneOut/run_$RUN


# Check if GEANT4 output directory exists
if ([ -d "$PATH_COSMIC_out/run_$RUN" ] && [ -z "${CLEAN_OUTPUT}" ]); then
    echo " [Warning] Geant4 output directory exists! Use -c option to delet existing files"
elif [ ! -z "${CLEAN_OUTPUT}" ]; then
    echo " Geant4 output directory exists! Deleting existing file..."
    \rm $PATH_COSMIC_out/run_$RUN/* -rf
fi


if [ -z "${PARTICLES_USER}" ]; then
    echo "Generating all particle: n, p, mu-, mu+, e-, e+"
    ./cosmic_gen -p 0 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_neutron.out
    ./cosmic_gen -p 1 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_proton.out
    ./cosmic_gen -p 29 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_muonbar.out
    ./cosmic_gen -p 30 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_muon.out
    ./cosmic_gen -p 31 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_electron.out
    ./cosmic_gen -p 32 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_electronbar.out
    ./cosmic_gen -p 33 -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_photon.out
else
    echo "Only generating PID - $PARTICLES_USER"
    ./cosmic_gen -p $PARTICLES_USER -n $NEVENTS
    \mv GeneOut/generation.out GeneOut/run_$RUN/generation_pid_$PARTICLES_USER.out
fi


cd ..
echo  $PATH_COSMIC_out
mkdir -p $PATH_COSMIC_out/run_$RUN
python process_cosmic.py `realpath parma_cpp/GeneOut/run_$RUN/` $PATH_COSMIC_out/run_$RUN   $SUBMIT

popd



# --------------------------------------------------------------------
# Run digitizer and tracker
if [ ! -z "${DIGITIZE}" ]; then
    echo "Running digitizer on cosmic sim result..."

    pushd ${digitizer_dir}
    i=0
    find $PATH_COSMIC_out/run_$RUN -type f -name "run0.root" | while read -r file; do
        echo "processing file ${file}"
        mkdir -p ${PATH_Digi_out}/cosmic_run_$RUN/$i
        # digitizer
        ./digitizer -l $file  -o ${PATH_Digi_out}/cosmic_run_$RUN/$i
        # tracker
        pytracker ${PATH_Digi_out}/cosmic_run_$RUN/$i/stat0.root ${PATH_Digi_out}/cosmic_run_$RUN/$i  --config $PATH_REPO/par_cards/tracker_config.py --overwrite
        ((i+=1))
    done    
    popd

fi



