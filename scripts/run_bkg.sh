
cp ~/jupyter/Background/scripts/proc_sm_muprod_matched /scratch/tomren/ -r
cd /scratch/tomren/




EventCount=10000


prefix="/project/def-mdiamond/tomren/"

mg5="${prefix}/mathusla/MG5_aMC_v3_4_2/bin/mg5_aMC"
mg5_script="${prefix}/jupyter/Background/scripts/card_run_matched.dat"
Extractor="${prefix}/jupyter/Background/scripts/hepmc_to_filereader.py"

# Hepmc files are saved on scratch
HepmcDir="/scratch/tomren/proc_sm_muprod_matched/Events/run_01"
# Output should be kept at safe place
OutputDir="/project/rrg-mdiamond/tomren/mudata/background/proc_sm_muprod_matched_filereader/"



for (( c=0; c<(${EventCount}/10000); c++ ))
do
  ${mg5} ${mg5_script}

  # Extract muons from the hepmc, save results in filereader format.
  # Extractor args: Extractor [Hepmc_filename] [filereader_input_filename]
  inputfilenames=${HepmcDir}/tag_*_pythia8_events.hepmc
  python3 ${Extractor} $inputfilenames ${OutputDir}/run_${c}_10000_events.txt
  
  # Delete the hepmc file
  rm -rf $HepmcDir
done