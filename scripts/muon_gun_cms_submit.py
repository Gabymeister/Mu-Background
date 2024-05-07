#!/usr/bin/env python3

from pathlib import Path
import sys,os

ana_helper_path = "/project/def-mdiamond/tomren/jupyter/Mu_helper/muhelper/"
sys.path.append(ana_helper_path)
from submit import *


def find_filereader_file(script_filename):
    with open(script_filename, "r") as f:
        contents = f.readlines()
    for line in contents:
        if "/gen/file_reader/pathname" in line:
            return line.split(" ")[1][:-1]

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--series', nargs='+', help='Series to process')
    parser.add_argument('--debug', action='store_true', help='Only show the commands without actually submitting jobs')
    parser.add_argument('--verbose', action='store_true', help='Show the slurm script content')
    parser.add_argument('--hours', type=int, default=6, help='Requested time in hours per job')
    parser.add_argument('--system', type=str, default='slurm', help='batch system, {slurm, lsf}')
    parser.add_argument('--slurm_account', type=str, default='rrg-mdiamond', help='Slurm system account')
    parser.add_argument('--slurm_partition', type=str, default='', help='Slurm system partition')
    
    args = parser.parse_args()
    Series = args.series #["25201106_180710"]#25201106_174906
    DEBUG     = args.debug
    verbose   =args.verbose
    hours = args.hours
    system = args.system
    slurm_account = args.slurm_account
    slurm_partition = args.slurm_partition    
    
    
    
    DataDir = '/project/rrg-mdiamond/tomren/mudata/background/test/'
    Log_Dir = f'{DataDir}/log/'

    simulation='/project/def-mdiamond/tomren/mathusla/Mu-Simulation/simulation '
    tracker='/project/def-mdiamond/tomren/mathusla/MATHUSLA-Kalman-Algorithm_debug/tracker/build/tracker '

    Pt_list    = [[8,12,20,30,35,40]] # GeV/c
    EventCount = 40000
    Scripts    = ['muon_gun_cms.mac']
    Names      = ["muon"]
    CORES      = 1
    

    # make directory for log
    os.system(f"mkdir -p {Log_Dir}")

    for i, sim_script in enumerate(Scripts):
        for energy in Pt_list[i]:
            subdir = f"{DataDir}/{Names[i]}_cms__Pt_{energy}_GeV"
            
            
            job_script=f"""mkdir -p {subdir}
# {simulation} -j1 -q  -o {subdir}  -s {sim_script} pt {energy} count {EventCount}  
for f in {subdir}/*/*/run*.root; do 
    {tracker} $f `dirname $f` 
    mv `dirname $f`/stat0.root `dirname $f`/stat_v1.root -f 
   
done 
"""
                
            # Set run-dependent cpu time
            if energy <30:
                hours_mod = int(EventCount/500/60)+1
            else:
                # continue
                hours_mod = int(EventCount/200/60)+1
            hours_mod = hours
            
                
            # This is the core function to submit job script
            script_prefix=sim_script.split("_")[0]
            submit_script(job_script, f"{script_prefix}_{energy}", blockidx=0, hours=hours_mod, cores=CORES, log_dir=Log_Dir, job_name="reco", system=system, slurm_account=slurm_account, slurm_partition='', debug=DEBUG, verbose=verbose)
            
if __name__ == "__main__":
    main()      