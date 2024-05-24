# How to run background simulation
## 1.1 MATHUSLA simulation workflow

There are three steps in general,

    Geant4 Simulation -> Digitizer -> Reconstruction

Link to G4 simulation/Digitizer:

Link to Reconstruction: 

This repository implements helper scripts to run the entire workflow for background study, including

1. Generating collider muon background with madgraph+pythia Geant4 simulation
2. Generating cosmic ray background with parma, run through Geant4 simulation
3. Running digitization. Two additional processes happen in this step:
    a. The cosmic ray simulation events are randomly choosed to add to the collider background simulation
    b. Detector noise are randomly added
4. Running track and vertex reconstruction

```
1.Madgraph+Pythia -> G4Sim 
                            \
                             3.Digitize-> 4.Reconstruction
                            /
2.PARMA cosmic gen-> G4Sim
```

## 1.2 Steps

First, make a directory and clone this repository. Then source the initialization script `init.sh`.  
This script will setup the environment, compile the `Geant4 simulation` and `Digiziter` code if the executable is not presented.

Second, run the script `run_all_bkg.sh` that implement the entire workflow described above.

```bash
mkdir background_gen; cd !$
git clone https://github.com/EdmondRen/Mu-Background.git; cd Mu-Background

source init.sh
./run_all_bkg.sh
```

## 1.3 \[IMPORTANT\] check these numbers if the simulation configuration changed

1. **Cosmic** (PARMA):
    1. The sphere radius used in PARMA. This number is the `radi` variable in cosmic/parma_cpp/main-generator-mathusla.cpp
    2. The cosmic ray flux. This is important because it will affect how many cosmic ray events should be added to the LHC background. use the jupyter notebook `cosmic/cosmic_check.ipynb` to check. Follow the instruction in the notebook.
    3. other random things, see the beginning of the source code cosmic/parma_cpp/main-generator-mathusla.cpp
2. **madgraph**:
    1. Madgraph cuts: scripts/madgraph/card_
    2. Geometry cuts: eta and phi in ??? -- NOT IMPLEMENTED YET
3. **Geant4**
4. **Digitizer**: par_cards/digitizer_par_card.txt
    1. Noise rate:
    2. Noise time window-- NOT IMPLEMENTED YET
    3. Cosmic rate:
    4. Scint efficiency:
5. **Reconstruction**: par_cards/tracker_config.py
    1. 

# 2. Details about the background study
## 2.1 Collider background

### Setting Up MadGraph and Pythia8

This version of the code uses MadGraph v3.5.1. MadGraph is a self-contained framework for simulating SM and BSM phenomenology, computing cross-sections, and generating hard-events. Pythia8 may also be installed in MadGraph, which simulates multi-state parton showers.

Reference:

    J. Alwall et al, "The automated computation of tree-level and next-to-leading order differential cross sections, and their matching to parton shower simulations"   
    Bierlich, Christian, et al. "A comprehensive guide to the physics and usage of PYTHIA 8.3." SciPost Physics Codebases (2022): 008.

Install:  

```bash
# # Install Pythia
# wget https://pythia.org/download/pythia83/pythia8306.tar
# tar -xf pythia8306.tar; rm pythia8306.tar; cd pythia8306
# ./configure
# make -j8
# cd ..

# Install Madgraph
module load StdEnv/2020 gcc/9.3.0 qt/5.12.8 root/6.26.06  eigen/3.3.7 geant4/10.7.3 geant4-data/10.7.3
mg5_version="MG5_aMC_v3_5_4"
mg5_version_download="MG5_aMC_v3.5.4"
wget http://launchpad.net/madgraph5/3.0/3.5.x/+download/${mg5_version_download}.tar.gz
tar -xzf ${mg5_version_download}.tar.gz
\rm ${mg5_version_download}.tar.gz
realpath ${mg5_version} # Print the full path of the installed Madgraph
cd $mg5_version
./bin/mg5_aMC
install pythia
exit 

```

You need to export the PYTHIA path if you need to run PYTHIA outside MadGraph:
```bash
export PYTHIA8=/project/6049244/data/MATHUSLA/bin/MG5_aMC_v3_5_4/HEPTools/pythia8
export PYTHIA8DATA=${PYTHIA8}/share/Pythia8/xmldoc
```


### Script for Running MadGraph ###

The script `run_MG5.sh` will run a series of MadGraph scripts. The script that it references can be found in the other repository "Mu-Simulation" found at https://github.com/Gabymeister/Mu-Simulation in the "VectorExtraction/MadGraphScripts directory." This will generate 50k MadGraph events with parton showering from pythia8, extract muon events, and reformat them for input into the Mu-Simulation. These will be stored in the "data/G4Input" directory. NOTE THAT THIS DIRECTORY MUST BE MADE BY THE USER FIRST. The script takes two inputs. The first is the Madgraph directory, the second is the minimum pT (in MeV) the user wishes to simulate using MadGraph.

### Script for Simulating the LHC ###
`run_lhc_muon.sh` is similar to `run_MG5.sh`, but it also runs the Geant4 "Mu-Simulation" as well. It stores the heavy Madgraph output files in the slurm job directory, so it MUST be submitted as a job script unless the user modifies it. It does not store the MadGraph output, which is deleted once the job is finished. It immediately runs the Geant4 MATHUSLA simulation, which is then stored in the shared MATHUSLA directory on ComputeCanada. This would be in `MATHUSLA/SimOutput/MG5`. The script takes three arguments. First, is the location of the MadGraph directory, second is the minimum pT in MeV, third is the number of MadGraph events to generate in ten-thousands (so 5 would generate 50k MG5 events).

## 2.2 Cosmic ray background


### Using the PARMA package

Package: PARMA is a C++ version of EXPAC, which is an analytical model for cosmic ray flux and spectrum. It can also be used as an event generator. Click download on https://phits.jaea.go.jp/expacs/
https://phits.jaea.go.jp/expacs/data/parma_cpp.zip.

Reference: 
    T.Sato, Analytical model for estimating terrestrial cosmic-ray fluxes nearly anytime and anywhere in the world; Extension of PARMA/EXPACS, 10(12): e0144679 (2015)
    T.Sato, Analytical model for estimating the zenith angle dependence of terrestrial cosmic ray fluxes, PLOS ONE, 11(8): e0160390 (2016)

Usage: 
For flux calculation, use main-simple.cpp.
For event generation, use main-generator.cpp as a reference. The output is saved in GeneOut.
You need to change the run condition in the code.

Compile:

    g++ main-generator.cpp subroutines.pp -o main-generator
    
Run:

    ./main-generator

### Adapt for mathusla simulation

The PARMA package is copied into `cosmic/parma_cpp` of this repository. main-generator-mathusla.cpp is a modified version of main-generator.cpp to suit the need of our simulation.

Changes:
* Accept parameter of particle type and number of events
* Use a random_device to seed the random number generator
* Parameters:
    * int iyear = 2023;     // Year
    * int imonth = 2;       // Month
    * int iday = 1;         // Day
    * double glat = 46.2330; // Cern Latitude (deg), -90 =< glat =< 90
    * double glong = 6.0557; // Cern Longitude (deg), -180 =< glong =< 180
    * double alti = 0.0;    // Altitude (km)
    * double g = 0.15;      // Local geometry parameter, 0=< g =< 1: water weight fraction, 10:no-earth, 100:blackhole, -10< g < 0: pilot, g < -10: cabin
    * double radi = 35.0;   // The radius is set to cover the entire 40x40x20m geometry. 

#### Compile: 

    g++ main-generator-mathusla.cpp subroutines.cpp -o cosmic_gen    
    
#### Usage:  

    ./cosmic_gen [-p PID] [-n NumberOfEvents]
    PID: Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
    
The generated particle will be saved as `cosmic/parma_cpp/GeneOut/generation.out`. There are seven columns: energy, u,v,w, x,y,z. Energy is the kinetic energy in MeV, (u,v,w) is the direction vector, (x,y,z) is the origin of the particle (all xyz are on a sphere)
    
### Script for generating cosmic ray events 

A bash script is made to streamline the simulation of cosmic ray events, see `run_cosmic.sh`. This script runs the PARMA generation of {neutron, proton, muon+, muon-, e+, e-, photon}. The number of each particle is normalized based on the flux so that we get the correct fraction of each species. The output of the all different particles are combined together, and a script for Geant4 simulation is generated.

The bash script calls a python script `process_cosmic.py` that further process the PARMA output and turn the format into a readable one by the G4Sim. A non exhaustive list of what is done in this step:
* The flux of each particle is collected
* The kinetic energy is converted to momentum in MeV/c
* The xyz value is added with an offset. The offset makes the Sphere to be center around the detector
* The time of the event is randomly sampled within a time window 0-600 ns. **Note that this is not very accurate.** 

The total flux of all the simulated particle is 0.047587973 /cm2/s. 
For normalization, the simulation results should be multiplied with the total flux (/cm2/s) and pi*radi*radi.
In our case, radi=35m, the event rate is 3.1415926*3500*3500 * 0.047587973 = 1831399 Hz 

Since the radius is larger than the actual detector, part of the simulation leaves no hits in the detector. A quick check shows that each recorded event corresponds to a flux of  0.01245836832471164 /cm2/s.
If we assume a coincidence window of 600 ns (200 ns is the time for light to go from one corner of the decay volume to the other, CMS->closest corner is 367 ns, to the furthest corner is 420ns), then the 

    average number of cosmic ray per event is 479454Hz * 600ns =  0.2876

This number is important when combining the cosmic ray simulation with the collider muon simulation. For each of the collider muon event, there should be  0.28767251536 cosmic ray events added on average within +/-300 ns time windows.

#### Parameters

Some of the parameters are hardcoded. Attention is needed to make sure those number matches the expectation.
The numbers are in the beginning of `process_cosmic.py`.

* t_max: this set the coinicidence time window, which is twice this number. Currently t_max is 300 ns. 200 ns is the time for light to go from one corner of the decay volume to the other, a factor of 1.5 is multiplied
* hit_offset_x: distance from CMS to detector center on the x direction (beamline)
* decay_volume_middle_height: height from ground to the middle of the decay volume
* cms_z: CMS z coordinate
* cosmic_radius: the radius used in PARMA. The number is used here to calculate the correct time offset




#### Usage of the script:

    ./run_cosmic.sh [-n NUMBER_OF_EVENTS (default is 10000)] [-r RUN_NUMBER (default is 1)] [-s SUBMIT_JOB ({True, False, Run}, defulat is False)] [-p PARTICLE (all particles will be generated if not specified)]
    
    PARTICLE: (Particle ID, 0:neutron, 1: proton, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
    
    
Example 1: **Use this script to generate all particles**:  `./run_cosmic.sh -n 1000 -r 1 -s Run`

Example 2: **Use this script to generate dedicated proton simulation for K-Long background study**: `./run_cosmic.sh -n 1000   -r 1   -s Run   -p 1`

## 2.3 Full Simulation ##

`full_sim.sh` executes both the LHC background and the cosmic background. It currently generates 50k MG5 events and 30k cosmic events. These are then sent to the Digitizer in the Mu-Simulation to be combined into a single file. Note that running 10 jobs will still generate 10 different root files once the digitizer is finished. 

# Reconstruction

pytracker stat0.root . --config=/home/tomren/jupyter/Background_gen/Mu-Background/par_cards/tracker_config.py --overwrite





    


