//
// ********************************************************************
// * License and Disclaimer                                           *
// *                                                                  *
// * The  Geant4 software  is  copyright of the Copyright Holders  of *
// * the Geant4 Collaboration.  It is provided  under  the terms  and *
// * conditions of the Geant4 Software License,  included in the file *
// * LICENSE and available at  http://cern.ch/geant4/license .  These *
// * include a list of copyright holders.                             *
// *                                                                  *
// * Neither the authors of this software system, nor their employing *
// * institutes,nor the agencies providing financial support for this *
// * work  make  any representation or  warranty, express or implied, *
// * regarding  this  software system or assume any liability for its *
// * use.  Please see the license in the file  LICENSE  and URL above *
// * for the full disclaimer and the limitation of liability.         *
// *                                                                  *
// * This  code  implementation is the result of  the  scientific and *
// * technical work of the GEANT4 collaboration.                      *
// * By using,  copying,  modifying or  distributing the software (or *
// * any work based  on the software)  you  agree  to acknowledge its *
// * use  in  resulting  scientific  publications,  and indicate your *
// * acceptance of all terms of the Geant4 Software license.          *
// ********************************************************************
//
/// \file TrackingAction.cc
/// \brief Implementation of the TrackingAction class
//
// 
//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......
//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

#include "action.hh"
#include "MuonDataController.hh"
#include "G4RunManager.hh"
#include "G4UnitsTable.hh"
#include "G4SystemOfUnits.hh"


namespace MATHUSLA { namespace MU {

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

TrackingAction::TrackingAction()
:G4UserTrackingAction()
 
{ 
}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

TrackingAction::~TrackingAction()
{
  
}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

void TrackingAction::PreUserTrackingAction(const G4Track* track)
{
}

//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......

void TrackingAction::PostUserTrackingAction(const G4Track* track)
{
MuonDataController* controller = MuonDataController::getMuonDataController();
if(!(controller->getOn())){return;}

   auto ParticleType=track->GetParticleDefinition()->GetPDGEncoding();
   
   //Determine that the track is a muon or anti-muon
   if((ParticleType !=13) && (ParticleType != -13)){return;} 
   const std::vector<const G4Track*>* secondariesInCurrentStep
                              = track->GetStep()->GetSecondaryInCurrentStep();
   size_t nbtrkCurrent = (*secondariesInCurrentStep).size();

   //Determine that the new decay has occured
   if(nbtrkCurrent !=3){return;}   
 

   auto CurrentPosition = track->GetPosition();
   double Z_Value = CurrentPosition.getX();
   double X_Value = CurrentPosition.getY();
   double Y_Value =-(CurrentPosition.getZ())+80*m;
   

   //Definitions for zone in which decay must occur to be saved
   G4double zmin = 70.0*m;
   G4double zmax = 170*m;
   G4double xmin = -49.5*m;
   G4double xmax = 49.5*m;
   G4double ymin = 60.03*m;
   //this is the bottom of the third scintilator from the top of the detector
   G4double ymaxZone = 87.095*m;  

 
   if( (xmin<X_Value) && (X_Value<xmax) 
    && (ymin<Y_Value) && (Y_Value<ymaxZone)
    && (zmin<Z_Value) && (Z_Value<zmax)){
    controller->setDecayInZone(true);
   G4cout<<"Set decay in zone true"<<G4endl;
    }   
   G4cout<<"Decay in zone status: "<<controller->getDecayInZone()<<G4endl;
     
}


//....oooOO0OOooo........oooOO0OOooo........oooOO0OOooo........oooOO0OOooo......
}}
