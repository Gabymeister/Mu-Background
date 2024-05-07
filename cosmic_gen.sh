# Usage
# ./cosmic_gen [-n NUMBER_OF_EVENTS (default is 10000)] [-r RUN_NUMBER (default is 1)]


NEVENTS=10000
RUN=1
SUBMIT="Run" # {True, False, Run}

while getopts n:r: flag
do
    case "${flag}" in
        n) NEVENTS=${OPTARG};;
        r) RUN=${OPTARG};;
    esac
done

# Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

pushd cosmic/parma_cpp
mkdir -p GeneOut/run_$RUN

./cosmic_gen -p 29 -n $NEVENTS
\mv GeneOut/generation.out GeneOut/run_$RUN/generation_muon.out
./cosmic_gen -p 30 -n $NEVENTS
\mv GeneOut/generation.out GeneOut/run_$RUN/generation_muonp.out
./cosmic_gen -p 31 -n $NEVENTS
\mv GeneOut/generation.out GeneOut/run_$RUN/generation_electron.out
./cosmic_gen -p 32 -n $NEVENTS
\mv GeneOut/generation.out GeneOut/run_$RUN/generation_electronp.out



cd ..
echo  $PATH_COSMIC_out
mkdir -p $PATH_COSMIC_out/run_$RUN
python process_cosmic.py `realpath parma_cpp/GeneOut/run_$RUN/` $PATH_COSMIC_out/run_$RUN   $SUBMIT



popd