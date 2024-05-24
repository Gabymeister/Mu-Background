#!/home/knownothing/anaconda3/bin/python3.10
# import pyhepmc
import os
import sys


z_cms = 85.47*1000 # z offset of CMS [mm]
hepmc_filename = f"{sys.argv[1]}"
filereader_filename = f"{sys.argv[2]}"


# Opens Hepmc File 
# Refer to: MG5_aMC_v3_5_2\madgraph\various\hepmc_parser.py
particles = [] # A list of [px, py, pz, PID], uint is GeV
with open(hepmc_filename,"r") as f:
    while True:
        line = f.readline()
        if not line:
            break    
        line = line.split(" ")
        
        # If it is a final state particle:
        if (line[0]=="P") and (line[8]=="1"):
            # Make cut on muons
            if ((line[2]=="13")|(line[2]=="-13")) :
                particles.append([float(line[3]), float(line[4]), float(line[5]), int(line[2])])
    print(f"  finished parsing hepmc. {len(particles)} muons found.")
    
# Write the file generator text
with open(filereader_filename,"w")  as f:
    f.write(f"# nevents {len(particles)}\n")
    for i in range(len(particles)):
        vertex = [0, 0, z_cms]
        f.write(f"n {i} 13                0.0             0.0             0.0              0.0              10.0                 -4000.0\n")
        f.write(f"\t {particles[i][3]} \t {vertex[0]} \t {vertex[1]} \t {vertex[2]}  \t {particles[i][2]*1000} \t {particles[i][0]*1000} \t {particles[i][1]*1000} \n")
        
    print(f"  filereader input saved: {filereader_filename}")
        
        
# with open(os.path.splitext(data_filename)[0]+".mac","w+")  as f:
#     f.write(f"/det/select Box \n")
#     f.write(f"/gen/select file_reader \n")
#     f.write(f"/gen/file_reader/pathname {os.path.abspath(data_filename)} \n")
#     f.write(f"/run/beamOn {sys.argv[4]} \n")

# # changes the seed in the MG5 generation script 
# file_line=[]
# with open(f"{sys.argv[3]}","r")  as s:
#     for line in s:
#         if "set seed" in line:
#             seed=[int(s) for s in line.split() if s.isdigit()]
#             line = f"set seed = {seed[0]+1}\n"
#             file_line.append(line)
#             continue
#         else:
#             file_line.append(line)
# with open(f"{sys.argv[3]}","w+")  as s:
#     for i in file_line:
#         s.write(f"{i}")

    

