#include <iostream>
#include "RunManager.hh"
#include "TString.h"
#include "util.hh"


int main(int argc, char *argv[]){

	if (argc < 5) {
		std::cout << "Usage:" <<std::endl;
		std::cout << "-l LHC_directory -c cosmic_directory -o output_dir_name" <<std::endl;
		return 0;
	}

	std::vector<TString> LHCfiles;
	std::vector<TString> CosmicFiles;
	TString outdir;

	int i = 1;
	while (i < argc) {
		if (strcmp("-l", argv[i]) == 0) {
			LHCfiles = io::ProcessDirectory(argv[i+1], "");
		} else if (strcmp("-c", argv[i]) == 0) {
			CosmicFiles = io::ProcessDirectory(argv[i+1], "");
		} else if (strcmp("-o", argv[i]) == 0) {
			outdir = TString(argv[i+1]);
		} else {
			std::cout << "Usage:" <<std::endl;
			std::cout << "-l LHC_directory -c cosmic_directory -o output_dir_name" <<std::endl;
			return 0;
		}
		i++;
	}
	
	RunManager RM;
	RM.SetOutputFile(outdir);

	for (auto f : LHCfiles ){
		std::cout << f << std::endl;
		RM.SetInputFile(f);
		RM.StartTracking();
	} 

	for (auto f : CosmicFiles ){
		std::cout << f << std::endl;
		RM.SetInputFile(f);
		RM.StartTracking();
	} 

	

		


	return 0;

} //main
