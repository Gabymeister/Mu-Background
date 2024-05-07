MomentumList=(40 100 300)

EventCount=10000

DataDir='/project/rrg-mdiamond/tomren/mudata/background/test/'
Script='muon_gun_cms.mac'

simulation='/project/def-mdiamond/tomren/mathusla/Mu-Simulation/simulation '
tracker='/project/def-mdiamond/tomren/mathusla/MATHUSLA-Kalman-Algorithm_debug/tracker/build/tracker '


for momentum in ${MomentumList[@]}
do
#   echo "mkdir -p ${DataDir}/muon_${energy}_GeV"
  # echo "simulation -j2 -o ${DataDir}/muon_${energy}_GeV -q -s $Script energy $energy count $EventCount"
#   for f in ${DataDir}/muon_${energy}_GeV/*/*/run*.root; do
#     # Run tracker for $TrackerRuns times
#     for ((irun=1; irun<=TrackerRuns;irun++)); do
#         echo "tracker $f `dirname ${f}`" 
#         #Rename the output for a unique index
#         echo "mv `dirname ${f}`/stat0.root `dirname ${f}`/stat${irun}.root"
#     done
#   done
#   mkdir -p ${DataDir}/muon_${energy}_GeV
#   ${simulation} -j2 -o ${DataDir}/muon_${energy}_GeV -q -s $Script energy $energy count $EventCount


  echo "simulation -j2 -o ${DataDir}/muon_cms_${momentum}_GeV -q -s $Script p $momentum count $EventCount"
 
  
done
