#!/bin/python
# Usage: python processing_cosmic.py <PARMA_OUTPUT_PATH> <GEANT4_OUTPUT_PATH> <submit?>  <cut>

import numpy as np
import argparse
import os
import sys
import glob

from pylab import *

import functools
print = functools.partial(print, flush=True)


# For auto cuts
op = {'+': lambda x, y: x + y,
      '-': lambda x, y: x - y,
      '>': lambda x, y: x > y,
      '<': lambda x, y: x < y,
      '=': lambda x, y: x == y}


# --------------------------------------------------------------------------------
# Detector variables
box_size=[40,40,20]
t_max = 200*1.5 # np.linalg.norm(box_size)/0.3

hit_offset_x = 90
hit_offset_y = 0
hit_offset_z = 20
decay_volume_middle_height = 0.8+13.6/2
cms_z = -85.47
cosmic_radius = 35 # radius of the target area in m

hit_plane_x = [hit_offset_x-box_size[0]*0.5, hit_offset_x+box_size[0]*0.5]
hit_plane_y = [hit_offset_y-box_size[1]*0.5, hit_offset_y+box_size[1]*0.5]
hit_plane_z = hit_offset_z
hit_time_offset_min = np.linalg.norm([hit_offset_x-box_size[0]*0.5, cms_z])/0.3 - cosmic_radius/0.3
hit_time_offset_max = np.linalg.norm([hit_offset_x+box_size[0]*0.5, cms_z+hit_offset_z, box_size[0]*0.5])/0.3 - cosmic_radius/0.3
time_window = [hit_time_offset_min - t_max*0.5, hit_time_offset_max+t_max*0.5] #  [ns] Time window needs to cover the time of flight from one corner to another. For 40mx40mx20m, the diagonal is 60m, divided by speed of ligh 0.3m/ns
print("Cosmic Hit time window", time_window, time_window[1]-time_window[0])
time_window = [0,600]
print("Actually, use", time_window, time_window[1]-time_window[0])


seed = 1
rng = np.random.default_rng(seed)

# --------------------------------------------------------------------------------
# Sim and tracker executable
# simulation='/home/owhgabri/scratch/My_Github/Mu-Simulation/simulation '
# digitizer='/home/owhgabri/scratch/My_Github/Mu-Simulation/digitizer '

# Handle arguments and parameters
parser = argparse.ArgumentParser()
parser.add_argument("parma_out_path", default="parma_cpp/GeneOut/")
parser.add_argument("sim_output_path", default="parma_cpp/GeneOut/")
parser.add_argument("run_geant_mode", default="False")
parser.add_argument("--cut_par", help="name of each parameter, seperated by ;. Valid parameters:x,y,z,px,py,pz,p,theta,phi")
parser.add_argument("--cut_op", help="operation to each parameter, seperated by ;. Valid operation: >,<,=. Example: <3")
parser.add_argument("--sim_option", help="Additional options for simulation")
args = parser.parse_args()
    
    
parma_out_path = os.path.abspath(args.parma_out_path)
sim_output_path = args.sim_output_path
sim_ops = args.sim_option

debug = True
run = False
verbose = False
if args.run_geant_mode=="True":
    debug=False
    run=False
elif args.run_geant_mode=="Run":
    run=True
    
cut=False    
all_cuts = []
if args.cut_par in ["x","y","z","px","py","pz","p","theta","phi"]:
    cut_pars = args.cut_par.split(";")
    cut_ops = args.cut_par.split(";")
    if len(cut_pars)==len(cut_ops):
        cut=True
        for i in range(len(cut_pars)):
            all_cuts.append([cut_pars[i], cut_ops[i][0],cut_ops[i][1:]])
        
output_name = parma_out_path + "/cosmic_filereader"
filenames = glob.glob(parma_out_path+"/generation*.out")        

# --------------------------------------------------------------------------------

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

# --------------------------------------------------------------------------------
# Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
pid_to_g4pid = {0:2112,
                1:2212,
                29:13,
                30:-13,
                31:11,
                32:-11,
               33:22}
particle_mass = {13:105.6583755, 
                 11:0.51099895,
                22:0,
                2112:940.6,
                2212:938.27} # labled with G4pid

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
    nevents_selected=0

    mass = particle_mass[abs(pid)]
    for i in range(nevents):
        energy, u, v, w, x, y, z = data[i][:] # !Energy is KINETIC ENERGY only!
        momentum = p = np.sqrt(energy**2 + 2*energy*mass) # [MeV]
        px, py, pz =  momentum* np.array([u,v,w])

        
        # Let's apply some cut if requested        
        # if cut:
        #     # theta and phi needs to be calculated first
        #     if "theta" in cut_pars:
        #         theta = np.arcsin(np.sqrt(px**2+py**2)/p)
        #     if "phi" in cut_pars:
        #         phi = np.arctan(py/px)  
                
        #     for cut_par, cut_op in zip(cut_pars, cut_ops):
                
        if energy < 2.67e3:
            continue
        
        data_combined["x"].append(x*10+hit_offset_x*1000)
        data_combined["y"].append(y*10+hit_offset_y*1000)
        data_combined["z"].append(-z*10)        
        data_combined["px"].append(px)
        data_combined["py"].append(py)
        data_combined["pz"].append(-pz)

        data_combined["t"].append(rng.uniform(time_window[0], time_window[1]))
        data_combined["pid"].append(pid)
        nevents_selected+=1
        
    total_events+=nevents_selected
    print(f"  events selected: {nevents_selected}/{len(data)}")        
    
print("Total events", total_events)
np.save(parma_out_path + f"/combined_{total_events}_events", data_combined)

# --------------------------------------------------------------------------------
# Convert to filereader output
filename_filereader=output_name+".txt"
with open(filename_filereader, "w") as file:
    file.write(f"# nevents {total_events}\n\n")
    for i in range(total_events):
        # Write vertex information
        file.write(f'E {i}  \t {data_combined["pid"][i]}\t  0.0 0.0 0.0 0.0 0.0 0.0 0.0\n')
        # Decay products
        file.write(f'P {data_combined["pid"][i]}  {data_combined["x"][i]} {data_combined["y"][i]} {data_combined["z"][i]} {data_combined["px"][i]} {data_combined["py"][i]} {data_combined["pz"][i]} {data_combined["t"][i]}\n')

# --------------------------------------------------------------------------------
# Make a Geant4 script 
sim_script_filename = generate_sim_script_filereader(filename_filereader)

# --------------------------------------------------------------------------------
# Make a bash script to call Geant and submit jobs
sim_ops = "" if sim_ops is None else sim_ops
run_script = f"""
pushd ${{simulation_dir}}
./simulation -q  -o {sim_output_path}  -s {sim_script_filename} {sim_ops}
popd
"""

job_script=f"""
{run_script}

echo "Run finished, cleaning input files"
\rm {parma_out_path} -rf

"""

if run:
    print(f"Running command: {run_script}")
    os.system(run_script)
else:
    submit_script(job_script, job_name=f"sim", run_number=0, hours=1, cores=1, log_dir=sim_output_path, slurm_account="rrg-mdiamond", slurm_partition='', debug=debug, verbose=verbose)






