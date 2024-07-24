import sys
import math
import os
# This program takes three arguments. 
# The first is the hepmc file. 
# The second is the parsed data file output.


def getRanges():
    ranges = {}
    with open(os.path.abspath(os.path.dirname(__file__)) + "/ranges.txt") as f:
        while True:
            line = f.readline()
            if not line:
                break
            line = line.split(" ")
            ranges[line[0]] = float(line[1])
    return ranges


def parse_hepmc(filename, ranges):
    particles = []
    i = 1
    firstParticle = True
    with open(filename) as f:
        while True:
            line = f.readline()
            if not line:
                break
            line = line.split(" ")

            if (line[0]=="E"):
                eventID = ["n", str(i)]
                firstParticle = True

            if (line[0]=="V"):
                # Setting this to Geant4 Coordinates
                #(x'=z, y'=x, z'=85470-y)
                position = [float(line[5]), float(line[3]), 85470-float(line[4])]
            # If it is a particle, is an end product, and is a muon or antimuon
            if (line[0]=="P") and (line[8]=="1") and ((line[2]=="13") or (line[2]=="-13")):
                    # Setting this to Geant4 coordinates and units to MeV/c
                    momentum = [1000*float(line[5]), 1000*float(line[3]), -1000*float(line[4])]
                    pT = math.sqrt(momentum[1]**2 + momentum[2]**2) 
                    eta = math.asinh(momentum[0]/pT)
                    phi = -math.asin(momentum[2]/pT)
                    if pT >= ranges["pTMin"] and pT <= ranges["pTMax"] \
                    and eta >= ranges["etaMin"] and eta <= ranges["etaMax"] \
                    and phi >= ranges["phiMin"] and phi <= ranges["phiMax"]:
                        if firstParticle:
                            particles.append(eventID)
                            firstParticle = False
                            i+=1
                        particle = [int(line[2])] + position + momentum
                        particles.append(particle)
    return particles



ranges = getRanges()
particles = parse_hepmc(sys.argv[1], ranges)
data = open(sys.argv[2], 'w')

nevents = 0
for entry in particles:
    if entry[0] == "n":
        nevents += 1
        line = entry[0] + " " + str(entry[1]) + " 0 .0 .0 .0 .0 .0 .0 "
    else:
        line = "\t" + str(entry[0]) + "\t" + str(entry[1]) + "\t" + str(entry[2]) + "\t" + str(entry[3]) + "\t" + str(entry[4]) + "\t" + str(entry[5]) + "\t" + str(entry[6])
    data.write(line)
    data.write('\n')
data.close()
