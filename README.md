# 2. Background generation
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

