#!/bin/bash

run_number=1
exposure_seconds=31536000  # One year of exposure
output_dir=/project/6049244/data/MATHUSLA/simulation/run-2024-07-cosmic-neutrino


# Argument 1: run nunber
if [ $# -gt 0 ]; then
    echo "Setting run number to $1"
    run_number=$1
fi

# Argument 2: exposure
if [ $# -gt 1 ]; then
    echo "Setting run number to $2"
    exposure_seconds=$2
fi


geometry_file=/project/6049244/data/MATHUSLA/bin/genie_data/geometry/world.box.root
crosssection_file=/project/6049244/data/MATHUSLA/bin/genie_data/genie_xsec/v3_04_00/NULL/G1802a00000-k250-e1000/data/gxspl-NUsmall.xml
FLUKA=/project/6049244/data/MATHUSLA/bin/genie_data/flux_table_fluka

cd $output_dir
mkdir genie -p
cd genie


# Just in case the environment variables got overwritten:
source /opt/mathusla/env.sh

# Run GENIE
# Options explained:
# -E  0.1,50  // set neutrino energy to 0.1,50 GeV
# -R X:0.0,3.14159265,0.0 // rotate the source by 180 degrees (because the geometry Z coordinate is pointing downwards)
# --flux-ray-generation-surface-distance and --flux-ray-generation-surface-radius // The sphere that the flux is sampled on

gevgen_atmo -f FLUKA:$FLUKA/ok_nue02.dat[12],$FLUKA/ok_numu02.dat[14],$FLUKA/ok_anue02.dat[-12],$FLUKA/ok_anumu02.dat[-14] \
    -g $geometry_file \
    -T $exposure_seconds \
    -r $run_number \
    --seed $run_number \
    -E 0.1,50  \
    -R X:0.0,3.14159265,0.0 \
    --flux-ray-generation-surface-distance 35 \
    --flux-ray-generation-surface-radius 35  \
    --cross-sections $crosssection_file \
    --message-thresholds $GENIE/config/Messenger_laconic.xml \
    > run_$run_number.log
    
# Convert to a readable root format
gntpc  -f rootracker -i gntp.$run_number.ghep.root 

echo "Run finished"