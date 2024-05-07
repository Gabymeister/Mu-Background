import numpy as np
import argparse
import os
import sys
import glob

from pylab import *


# Detector
box_size=[40,40,20]
t_max = np.linalg.norm(box_size)/0.3
time_window = [-t_max, t_max] #  [ns] Time window needs to cover the time of flight from one corner to another. For 40mx40mx20m, the diagonal is 60m, divided by speed of ligh 0.3m/ns
hit_offset_x = 70
hit_offset_y = box_size[1]*-0.5
hit_offset_z = 14

seed = 1


# Sim and tracker executable
simulation='/project/def-mdiamond/tomren/mathusla/Mu-Simulation/simulation '
tracker2="python3 /home/tomren/jupyter/pyTracker/tracker/run.py "






hit_plane_x = [hit_offset_x, hit_offset_x+box_size[0]]
hit_plane_y = [hit_offset_y, hit_offset_y+box_size[1]]
hit_plane_z = hit_offset_z

rng = np.random.default_rng(seed)


# Handle arguments and parameters
path = "parma_cpp/GeneOut/"
if len(sys.argv)>1:
    path = sys.argv[1]
    
path = os.path.abspath(path)
output_name = path + "/cosmic_filereader"
filenames = glob.glob(path+"/generation*.out")
sim_output_path = "parma_cpp/GeneOut/"
if len(sys.argv)>2:
    sim_output_path = sys.argv[2]
debug = True
run = False
verbose = False
if len(sys.argv)>3:
    if sys.argv[3]=="True":
        debug=False
        run=False
    elif sys.argv[3]=="Run":
        run=True


def cosmic_info(filename):
    with open(filename, "r") as fin:
        line = fin.readline()
        pid = int(re.findall(r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", line)[0])
        
        line = fin.readline()
        flux = float(re.findall(r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", line)[-1])
    return pid, flux

def cosmic_data(filename):
    data = np.loadtxt(filename, skiprows=3)
    return data


def generate_sim_script_filereader(events_properties_filename, script_path=None):
    """
    Create simulation script for filereader generator based on the events database file.
    """
    if script_path is None:
        script_path = os.path.splitext(events_properties_filename)[0]+".mac"
        
    with open(events_properties_filename, 'r') as file:
        nlines_read=0
        found_nevents=False
        while (not found_nevents) and nlines_read<=10:
            line_content = file.readline().split()
            nlines_read+=1
            if "nevents" in line_content:
                try:
                    nevents = int(line_content[-1])
                    found_nevents = True
                    break
                except:
                    print("Could not read number of events")
            

    script = "/det/select Box \n"
    script+= "/gen/select file_reader \n"
    script+= f"/gen/file_reader/pathname {events_properties_filename}\n"
    script+= f"/run/beamOn {nevents}"

    with open(script_path, 'w') as file:
        file.write(script)
        
    print("Script saved at", script_path)
    
    return script_path



import os
def insert (source_str, insert_str, pos):
    return source_str[:pos]+insert_str+source_str[pos:]
def submit_script(script, job_name, run_number, hours, log_dir, cores=1, ram=2048, slurm_account="", slurm_partition="", debug=True, verbose=False):
    slurm_command = \
    f"""#!/bin/bash
#SBATCH --job-name={job_name}_{run_number}
#SBATCH --output={log_dir}/{job_name}_{run_number}.out
#SBATCH --error={log_dir}/{job_name}_{run_number}.err
#
#SBATCH --ntasks=1
#SBATCH --cpus-per-task={cores}
#SBATCH --mem-per-cpu={ram}M
#
#SBATCH --time={hours}:00:00

{script}"""

    if len(slurm_account)!=0:
        slurm_command = insert(slurm_command,f"#SBATCH --account={slurm_account}\n",slurm_command.find('#SBATCH --job-name'))
    if len(slurm_partition)!=0:
        slurm_command = insert(slurm_command,f"#SBATCH --partition={slurm_partition}\n",slurm_command.find('#SBATCH --job-name'))            

    script_path = f"{log_dir}/{job_name}_{run_number}.sh"
    with open(script_path, 'w') as file:
        file.write(slurm_command)
    full_command = f"sbatch {script_path}"  

    if verbose:        print("    (DEBUG) SLURM script:", slurm_command)
    if debug:          print("    (DEBUG) SLURM command:", full_command)

    if not debug:
        os.system(full_command)

# Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
pid_to_g4pid = {29:13, 30:-13, 31:11, 32:-11}
particle_mass = {13:105.6583755, 11:0.51099895} # labled with G4pid

# Read the flux of each data type
file_info={}
flux_total=0
flux_max=0
for i in range(len(filenames)):
    pid,flux = cosmic_info(filenames[i])
    file_info[i] = [pid_to_g4pid[pid], flux]
    flux_total +=flux
    flux_max = max(flux_max,flux)
    
print("Total flux", flux_total, "[/cm2/s]")
print(file_info)
    
# Merge and save 
# energy and direction is converted to px, py, pz [MeV] for use with Geant4 filereader generator
data_combined={}
data_combined["pid"]=[]
data_combined["px"]=[]
data_combined["py"]=[]
data_combined["pz"]=[]
data_combined["x"]=[]
data_combined["y"]=[]
data_combined["z"]=[]
data_combined["t"]=[]

total_events = 0
for i in range(len(filenames)):
    print("Processing",filenames[i])
    [pid, flux] = file_info[i]
    data = cosmic_data(filenames[i])
    nevents = int(flux/flux_max*len(data))
    total_events+=nevents
    print(f"  events selected: {nevents}/{len(data)}")
    mass = particle_mass[abs(pid)]
    for i in range(nevents):
        energy, u, v, w, x, y, z = data[i][:]
        px, py, pz =  energy* np.array([u,v,w]) #np.sqrt(energy**2-mass**2)
        x, y, z = rng.uniform(*hit_plane_x), rng.uniform(*hit_plane_y), hit_plane_z
        data_combined["pid"].append(pid)
        data_combined["px"].append(px)
        data_combined["py"].append(py)
        data_combined["pz"].append(-pz)
        data_combined["x"].append(x*1000)
        data_combined["y"].append(y*1000)
        data_combined["z"].append(-z*1000)
        data_combined["t"].append(rng.uniform(*time_window))
    
print("Total events", total_events)
np.save(path + f"combined_{total_events}_events.npz", data_combined)



# Convert to filereader output
filename_filereader=output_name+".txt"
with open(filename_filereader, "w") as file:
    file.write(f"# nevents {total_events}\n\n")
    for i in range(total_events):
        # Write vertex information
        file.write(f'E {i}  \t {data_combined["pid"][i]}\t  0.0 0.0 0.0 0.0 0.0 0.0 0.0\n')
        # Decay products
        file.write(f'P {data_combined["pid"][i]}  {data_combined["x"][i]} {data_combined["y"][i]} {data_combined["z"][i]} {data_combined["px"][i]} {data_combined["py"][i]} {data_combined["pz"][i]} {data_combined["t"][i]}\n')
        

        
        
# Make a Geant4 script 
sim_script_filename = generate_sim_script_filereader(filename_filereader)




# Make a bash script to call Geant and submit jobs
job_script=f"""
export PYTHIA8=/project/def-mdiamond/tomren/mathusla/pythia8308
export PYTHIA8DATA=$PYTHIA8/share/Pythia8/xmldoc
PATH=$PATH:/project/def-mdiamond/tomren/mathusla/dlib-19.24/install
module load StdEnv/2020 gcc/9.3.0 qt/5.12.8 root/6.26.06  eigen/3.3.7 geant4/10.7.3 geant4-data/10.7.3


{simulation} -j1 -q  -o {sim_output_path}  -s {sim_script_filename}  
"""

if run:
    print(f"Running command: {job_script}")
    os.system(job_script)
else:
    submit_script(job_script, job_name=f"sim", run_number=0, hours=1, cores=1, log_dir=sim_output_path, slurm_account="rrg-mdiamond", slurm_partition='', debug=debug, verbose=verbose)






