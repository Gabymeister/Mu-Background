import pickle
import numpy as np
import ROOT
# import uproot
try:
    from tqdm import tqdm
except:
    def tqdm(iterator, *args, **kwargs):
        return iterator
    
import joblib

import copy
import sys, os
import glob, re
from collections import namedtuple
particle = namedtuple('particle', ['X_S', 'Y_S', 'Z_S', 'X_END_S', 'Y_END_S', 'Z_END_S', 'PX_S', 'PY_S', 'PZ_S', 'PX_END_S', 'PY_END_S', 'PZ_END_S', 'PDG', 'TRACK', 'TRACK_PARENT', "TRACK_STATUS", 'TRACK_DECAYED', 'entry', "filenumber"])


def extract_kaon_event_fast(data, run_number):
    result = []
    added_tracks = {}
    for i in range(len(data["PDG"])):
        # if (data["PDG"][i] in [130,310, 311, -311]) & \
        #     (data["TRACK"][i] not in data["TRACK_PARENT"]):
        if (data["PDG"][i] in [130,310, 311, -311]):
            track_number = data["TRACK"][i]
            track_decayed = 1 if (data["TRACK"][i] not in data["TRACK_PARENT"]) else 0
            track = [data['X_S'][i],data['Y_S'][i],data['Z_S'][i],\
                                   data['X_END_S'][i],data['Y_END_S'][i],data['Z_END_S'][i],\
                                   data['PX_S'][i],data['PY_S'][i],data['PZ_S'][i],\
                                   data['PDG'][i],data['TRACK'][i],data['TRACK_PARENT'][i],data['TRACK_STATUS'][i], 
                                    track_decayed,
                                   data['EVENT_NUMBER'][i]]
            if track_number not in added_tracks:
                added_tracks[track_number] = [track]
            else:
                added_tracks[track_number].append(track)
            
                
    for tr in added_tracks:
        if len(added_tracks[tr])==1:
            track=added_tracks[tr][0]
            result.append(particle(*track[:9],*track[6:9], *track[9:], run_number))
        else:
            all_tracks=np.array(added_tracks[tr])
            track=added_tracks[tr][0]
            # Start with one end of the track
            track_merged = [*track[:9],*track[6:9], *track[9:]]
            # Replace the end position and momentum
            track_merged[3] = added_tracks[tr][-1][3]
            track_merged[4] = added_tracks[tr][-1][4]
            track_merged[5] = added_tracks[tr][-1][5]
            track_merged[3+6] = added_tracks[tr][-1][3+3]
            track_merged[4+6] = added_tracks[tr][-1][4+3]
            track_merged[5+6] = added_tracks[tr][-1][5+3]            
            track_merged[-3] = added_tracks[tr][-1][-3]
            result.append(particle(*track_merged, run_number))
            # print()
            # print(added_tracks[tr])
            # print(result[-1])
            
                
    return result


def extract_kaon(filename_root):
    ## using uproot
    tfile = ROOT.TFile.Open(filename_root)
    # file = uproot.open(filename_root)
    # tree_names = file.keys()
    ## Get the run number
    run_number = re.search(r'run_(\d+)', filename_root).group(1)
    
    tree_names = [i.GetName() for i in  tfile.GetListOfKeys()]
    print("Events with KL/KS", len(tree_names))
    
    results = []
    for tree_name in tree_names:
    # for tree_name in tqdm(tree_names):
        ttree = tfile.Get(tree_name)
        entries = ttree.GetEntries()
        if entries==0:
            continue
        
        # Tree = file[tree_name].arrays(['X_S', 'Y_S', 'Z_S', 'X_END_S', 'Y_END_S', 'Z_END_S', 'PX_S', 'PY_S', 'PZ_S', 'PDG', 'TRACK', 'TRACK_PARENT'], library="np")
        data = tree2array(ttree)
        res_partial = extract_kaon_event_fast(data, run_number)
        results.extend(res_partial)
            
    return results

def tree2array(Tree, branches=None):
    # tfile = ROOT.TFile.Open(filename)
    # Tree = tfile.Get(treename)
    branches = [Tree.GetListOfBranches()[i].GetName() for i in range(len(Tree.GetListOfBranches()))] if branches is None else branches
    results = {br:[] for br in branches}
    for i in range(Tree.GetEntries()):
        Tree.GetEntry(i)
        for br in results:
            results[br].append(getattr(Tree,br))
    return results


# def extract_kaon2(filename_root):
#     tfile = ROOT.TFile.Open(filename_root)
#     tree_names = [i.GetName() for i in  tfile.GetListOfKeys()]
#     print("Events with KL/KS", len(tree_names))
    
#     results = []
#     print("4323")
#     Tree = tfile.Get("event_4323")
#     Tree.GetEntry(0)
#     print("event_4349")
#     Tree = tfile.Get("event_4339")
#     Tree.GetEntry(0)   
#     print("event_4349")
#     Tree = tfile.Get("event_4349")
#     Tree.GetEntry(0)       
    
#     for tree_name in tree_names:
#         Tree = tfile.Get(tree_name)
#         entries = Tree.GetEntries()
#         if entries==0:
#             continue
            
#         print(tree_name)
        
#         # Read TTree into a dict
#         branches = [Tree.GetListOfBranches()[i].GetName() for i in range(len(Tree.GetListOfBranches()))]
#         data = {br:[] for br in branches}
#         Tree.GetEntry(0)
#         print(Tree.GetName())
#         del Tree
        
#         # for i in range(Tree.GetEntries()):
#         #     Tree.GetEntry(i)
#         #     for br in results:
#         #         data[br].append(getattr(Tree,br))
            
            
#         res_partial = extract_kaon_event_fast(data)
#         results.extend(res_partial)
            
#     return results

def main():
    filename = sys.argv[1]
    filename_save = sys.argv[1].replace(".root", "_kaons.joblib")
    
    try:
        data = extract_kaon(filename)
        joblib.dump(data, filename_save)
        print("  finished",filename)
    except Exception as e:
        print("error loading root file: ", e)

if __name__ == "__main__":
    main()