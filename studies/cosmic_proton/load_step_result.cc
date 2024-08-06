#include "TFile.h"

int load_step_result(){
    auto run_dir = "/project/rrg-mdiamond/data/MATHUSLA//simulation/run-2024-07-cosmic-proton/";
    auto filename = "/project/rrg-mdiamond/data/MATHUSLA//simulation/run-2024-07-cosmic-proton//SimOutput/cosmic/run_9/20240726/203654/run_step_data.root";



    TFile stepfile(filename);


    for (auto&& keyAsObj : *stepfile.GetListOfKeys()){
     auto key = (TKey*) keyAsObj;
     cout << key->GetName() << " " << key->GetClassName() << endl;
    }

}
