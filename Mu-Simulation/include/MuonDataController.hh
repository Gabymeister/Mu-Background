
#ifndef FiveBodyDataController_h
#define FiveBodyDataController_h 1

#include <iostream>
#include <action.hh>
#include <stdlib.h>
#include "globals.hh"


namespace MATHUSLA { namespace MU {

class MuonDataController
{
public:
    MuonDataController();
    virtual ~MuonDataController();
    
    static MuonDataController* getMuonDataController();
    virtual void setDecayInEvent(G4bool);
    virtual G4bool getDecayInEvent();   

    std::vector<G4double> p1x, p1y, p1z, p2x, p2y, p2z, p3x, p3y, p3z;
    void getParticles(G4int, G4double*);
    void getRandomParticles(G4double*);
    void incrementMuonDecays();
    virtual G4bool getRandom();
    virtual G4int getMuonDecays();
    virtual void setRandom(G4bool);
    virtual void setMuonDecays(G4int);
    virtual void setOn(G4bool);
    virtual G4bool getOn();
    virtual G4bool getDecayInZone();
    virtual void setDecayInZone(G4bool);
    virtual G4int getEventsWithDecay();
    virtual void incrementEventsWithDecay(G4int);        
private:
   //static instance of the MuonDataController
   static MuonDataController* sController;
   G4int i =0;
   //Is the order of the deays random
   G4bool Random;
   //Are Five-Body Decays turned on
   G4bool decaysOn;
   //The total number of Five-Body decays which have occured
   G4int MuonDecays =0;
   G4String e1x, e1y, e1z, e2x, e2y, e2z, e3x, e3y, e3z;
   //Has there been a five-body decay in this event
   G4bool DecayInEvent;
   //Has the five-body decay occured in the zone defined in tracking action
   G4bool DecayInZone;
   //How many total events had a five-body decay
   G4int eventsWithDecay = 0;

};
}}
#endif
