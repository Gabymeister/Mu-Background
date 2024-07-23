import sys
import re
import math

PREFIX = "/bkg_muon_"

phi_min = -0.21
phi_max = 0.21
eta_max = 1.32
eta_min = 0.833

eta_range = [100000, -100000]
phi_range = [100000, -100000]

# Order of inputs:
#   1. Directory where the final text file and corresponding macro will be stored
#   2. ID number of the job as given by the slurm job manager
#   3. Number of sets (i.e. the number of times MadGraph ran in a single job)
#   4. Path to the temporary directory created by the slurm job manager
# Resetting the file so that it does not combine different data
open(str(sys.argv[1]) + PREFIX + str(sys.argv[2]) + ".txt", 'w').close()
in_range = 0
TotalEvents = 0
TotalMuons = 0
for i in range(int(sys.argv[3])):

    # Opening the first text file to add
    readFile = open(str(sys.argv[4]) + PREFIX + str(sys.argv[2]) + "_" + str(i) + ".txt", 'r')
    lines = readFile.readlines()

    FileEvents = 0
    curindex = -1
    #Iterate backwards to find the number of events in the File
    while True:
        curline = lines[curindex]
        if "n" in curline:
            FileEvents = int(re.findall(r'\d+', curline)[0])
            break
        else:
            curindex = curindex - 1
    readFile.close()
    # Appending the data from the different files to the new main file, adjusting the event number as well
    combined = open(str(sys.argv[1]) + PREFIX + str(sys.argv[2]) + ".txt", 'a')
    for line in lines:
        if 'n' in line:
            eventNum = int(re.findall(r'\d+', line)[0])
            # Combining files, so add based on total so far
            line = "n " + str(eventNum + TotalEvents) + " 0 .0 .0 .0 .0 .0 .0  \n"
        else:
            TotalMuons += 1
            data = line.split()
            phi = math.atan(float(data[5])/float(data[4]))
            eta = math.atanh(float(data[4])/math.sqrt(float(data[4])**2 + float(data[5])**2 + float(data[6])**2))
            if phi < phi_range[0]:
                phi_range[0] = phi
            elif phi > phi_range[1]:
                phi_range[1] = phi
            if eta < eta_range[0]:
                eta_range[0] = eta
            elif eta > eta_range[1]:
                eta_range[1] = eta
            if phi >= phi_min and phi <= phi_max and eta >= eta_min and eta <= eta_max:
                in_range += 1
        combined.write(line)
    combined.close()
    TotalEvents += FileEvents

print("Total Events:", TotalEvents)
print("Total Muons:", TotalMuons)
print("Events towards detector:", in_range)
print("Eta ranges:", eta_range)
print("Phi ranges:", phi_range)

# Writing the Macro
macro = open(sys.argv[1] + PREFIX + str(sys.argv[2]) + ".mac", 'w')
macro.write("/det/select Box\n")
macro.write("/gen/select file_reader\n")
# The file name is bkg_muon_<job number>.txt
macro.write("/gen/file_reader/pathname " + sys.argv[1] + PREFIX + sys.argv[2] + ".txt\n")
macro.write("/run/beamOn " + str(TotalEvents) + "\n")
macro.close()
