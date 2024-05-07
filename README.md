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

First, make a directory and clone this repository. Then source the initialization script. 
This script will setup the environment, compile the `Geant4 simulation` and `Digiziter` code if the executable is not presented.

Second, run the script `run_all_bkg.sh` that implement the entire workflow described above.

```bash
mkdir background_gen
cd !$

git clone https://github.com/EdmondRen/Mu-Background.git
cd Mu-Background

source init.sh
./run_all_bkg.sh
```

# 2. Details about the background under study
## 2.1 CMS background
## 2.2. Cosmic ray

### General information

Package: C++ version of EXPAC, click download on https://phits.jaea.go.jp/expacs/
https://phits.jaea.go.jp/expacs/data/parma_cpp.zip. This is an analytical model for cosmic ray flux.

Reference: 
    T.Sato, Analytical model for estimating terrestrial cosmic-ray fluxes nearly anytime and anywhere in the world; Extension of PARMA/EXPACS, 10(12): e0144679 (2015)
    T.Sato, Analytical model for estimating the zenith angle dependence of terrestrial cosmic ray fluxes, PLOS ONE, 11(8): e0160390 (2016)

Usage: 
For flux calculation, use main-simple.cpp.
For event generation, use main-generator.cpp as a reference. The output is saved in GeneOut.
You need to change the run condition in the code.

Compile: g++ main-generator.cpp subroutines.pp -o main-generator
Run: ./main-generator

### For mathusla simulation

