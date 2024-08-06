import os, sys

joblist = os.popen("sq").read().split("\n")

job_prolog=[]
job_prolog_ind=[]
for job in joblist:
    if "Prolog" in job:
        jogstatus=job.split()
        
        # Only care about running jobs
        if jogstatus[4]!="R":
            continue
            
        job_prolog.append(job.split()[0])
        job_prolog_ind.append(job.split()[0].split("_")[1])
    
print("Number of jobs in Prolog",len(job_prolog))    
print(*job_prolog, sep=" ")
print(*job_prolog_ind, sep=",")
        
        