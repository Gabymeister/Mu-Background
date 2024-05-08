import sys
import re

PREFIX = "/bkg_muon_"

# Order of inputs ${G4SimFiles} ${SLURM_ARRAY_TASK_ID} ${NumSets} ${SLURM_TMPDIR}
# Resetting the file so that it does not combine different data
open(str(sys.argv[1]) + PREFIX + str(sys.argv[2]) + ".txt", 'w').close()

TotalEvents = 0
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
         line = "n " + str(eventNum + TotalEvents) + '\n'
      combined.write(line)
   combined.close()
   TotalEvents += FileEvents

# Writing the Macro
macro = open(sys.argv[1] + PREFIX + str(sys.argv[2]) + ".mac", 'w')
macro.write("/det/select Box\n")
macro.write("/gen/select file_reader\n")
# The file name is bkg_muon_<job number>.txt
macro.write("/gen/file_reader/pathname " + sys.argv[1] + PREFIX + sys.argv[2] + ".txt\n")
macro.write("/run/beamOn " + str(TotalEvents) + "\n")
macro.close()
