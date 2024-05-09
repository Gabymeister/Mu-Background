# Usage
# ./run_cosmic.sh [-n NUMBER_OF_EVENTS (default is 10000)] [-r RUN_NUMBER (default is 1)] [-s SUBMIT_JOB ({True, False, Run}, defulat is False)] [-p PARTICLE]
# Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

NEVENTS=10000
RUN=1
SUBMIT="False" # {True, False, Run}
PARTICLES=(0 1 29 30 31 32 33)
PARTICLES_USER=
OVERWRITE=

usage() { echo "Usage: $0 [-n NUMBER_OF_EVENTS] [-r RUN_NUMBER] [-s SUBMIT_JOB {True, False, Run}] [-p PARTICLE]" 1>&2; echo "Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)"; exit 1; }
while getopts n:r:s:p:hf flag
do
    case "${flag}" in
        n) NEVENTS=${OPTARG};;
        r) RUN=${OPTARG};;
        s) SUBMIT=${OPTARG};;
        p) PARTICLES_USER=${OPTARG};;
        f) OVERWRITE=1;;
        h) usage;;
    esac
done

pushd cosmic/parma_cpp

# Check if directory exists
if ([ -d "GeneOut/run_${RUN}" ] && [ -z "${OVERWRITE}" ]); then
    echo "Directory exists! Use -f option to overwrite. Exiting..."
    exit 1
elif [ ! -z "${OVERWRITE}" ]; then
    echo $OVERWRITE
    echo "Directory exists! Deleting existing file..."
    \rm GeneOut/run_$RUN/* -rf
fi
mkdir -p GeneOut/run_$RUN


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
