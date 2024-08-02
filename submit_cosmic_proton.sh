#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --account=rrg-mdiamond
#SBATCH --array=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,113,116,118,119,120,121,122,123,124,125,128,129,130,131,132,133,134,135,136,138,139,140,141,142,144,145,146,148,149,150,151,154,156,158,159,161,163,164,165,166,167,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,187,189,190,191,192,193,194,197,198,200,201,203,204,205,208,209,210,211,212,215,216,217,218,219,221,224,225,226,227,228,229,230,231,232,233,234,237,238,239,240,241,242,243,245,247,248,249,250,251,252,253,255,256,257,258,259,260,262,263,264,265,266,267,268,269,270,273,274,275,276,277,278,280,281,282,283,285,286,287,289,291,295,296,297,299,300,301,302,304,305,306,307,310,311,313,314,315,316,317,318,319,320,322,324,325,326,327,328,329,330,331,332,333,334,336,337,338,339,341,343,347,349,352,353,354,355,356,357,358,359,362,363,364,366,367,368,369,371,372,373,374,375,376,378,379,380,385,386,388,389,390,391,392,393,398,400,401,402,403,404,405,406,407,412,413,414,415,416,417,418,419,420,422,423,424,425,428,429,430,431,432,433,434,435,436,437,439,440,443,444,445,449,450,451,452,453,454,455,456,458,459,460,463,465,466,467,469,471,472,476,477,479,480,482,483,484,486,487,488,490,491,492,493,494,495,496,497,498,499,500,501,502,503,506,508,509,511,512,513,514,515,516,517,518,519,520,523,525,526,528,529,531,532,533,534,535,536,537,538,539,540,542,543,544,545,546,547,548,549,550,551,553,554,555,556,558,560,561,562,564,565,566,567,568,569,570,571,572,573,575,576,577,578,579,580,581,582,583,584,585,587,589,590,593,594,595,596,597,600,601,602,604,606,607,608,609,611,612,614,615,616,617,620,621,622,623,625,626,628,629,630,632,633,634,635,637,639,641,642,645,647,650,651,653,654,655,656,657,659,660,661,662,663,664,666,667,669,670,671,672,675,677,678,679,680,681,682,683,685,686,687,688,689,690,691,692,693,694,697,698,699,700,701,702,703,704,705,708,709,710,711,713,714,716,719,720,721,724,725,727,728,729,730,732,733,738,739,740,741,742,743,744,745,746,747,748,751,752,753,754,755,756,758,761,762,763,764,765,768,769,770,773,774,775,776,777,778,781,782,783,784,786,787,788,789,790,793,795,796,797,799,800,801,802,806,808,809,810,811,812,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,830,831,833,834,835,836,837,838,839,840,841,844,845,846,848,850,851,852,853,856,857,858,859,860,861,862,863,866,869,870,873,875,877,880,882,883,884,885,887,888,889,890,892,894,895,896,897,898,899,902,903,904,905,907,909,910,911,912,913,915,916,917,918,920,921,923,924,925,928,929,930,931,933,935,936,941,942,943,944,946,948,949,950,951,952,953,954,956,957,958,959,962,963,965,966,967,968,969,970,971,972,973,974,975,976,977,978,979,980,981,982,983,984,987,988,989,991,992,994,995,996,998,1000
#SBATCH --mem=4G
#SBATCH --constraint=cascade

#SBATCH --job-name=mu-cosmic
#SBATCH --output=scripts/slurm_log/log-mu-cosmic_%a.out


# SLURM_ARRAY_TASK_ID=0

N_EVENTS=5000
# PARTICLE to run. All for all particles, or select one from
# 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon
PARTICLE=1


#############################################
## HELP:
## Change the --array option above to the number of job you would like to run
#     --array=START-END, for example, 1-2 will run two jobs with SLURM_ARRAY_TASK_ID = 1 and 2
## Run the following command to submit jobs:
# --output=${PATH_COSMIC_out}/log-mu-cosmic_%a.out
#     sbatch  submit_cosmic.sh
## Check the code below, comment out the ones that you do not need
#############################################




##--------------------------------------------
# Option 1: Run all particles except 2-28
# argument n sets the number of events. n=100_000 takes ~50-100 minutes
# argument p sets the particle type. Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)


[ "$PARTICLE" = "ALL" ] && ./run_cosmic_proton.sh  -n $N_EVENTS -r ${SLURM_ARRAY_TASK_ID} -s Run -d -f -c




##--------------------------------------------
# Option 2: Run single particle
# argument n sets the number of PARMA events. 
#    n=100_000 generates about ~43k events in the detector while ~20k are good tracks, and takes ~50 minutes
#    n=400_000 takes ~180 minutes
#    However, some nodes can be a factor of two slower..... So budget for more time when submitting the jobs
#    6 hours for 400k events seems sufficient. 
# argument p sets the particle type. Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)

# In order to get enough events for all channels, 100e3/6 * 500=~8M muon events needed. 
#  --> 8/0.2 = 40 M PARMA events. 400k events per run--> 100 runs
# Storage: 20MB (Sim+Digi+Recon) for ~2k of (recorded) events, --> 2 kB per event, 16 GB for 8M of events

[ "$PARTICLE" = "ALL" ] || ./run_cosmic_proton.sh  -n $N_EVENTS -r ${SLURM_ARRAY_TASK_ID} -s Run -p $PARTICLE -d -f -c


# # Remove the PARMA output file
# rm ~/data/simulation/run-2024-07-cosmic-proton/SimInput/cosmic/run_${SLURM_ARRAY_TASK_ID}/generation_pid_1.out


# # Extract kaons from the step files
# run_dir="/project/rrg-mdiamond/data/MATHUSLA//simulation/run-2024-07-cosmic-proton/"
# step_files_pattern="$run_dir/SimOutput/cosmic/run_${SLURM_ARRAY_TASK_ID}/*/*/run_step_data.root"
# step_files=( $step_files_pattern )

# echo
# echo "Parsing the step file"
# for i in "${step_files[@]}"
# do
#     python3 ./studies/cosmic_proton/extract_kaons.py  $i
# done
