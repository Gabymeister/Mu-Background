#include<iostream>
#include <TLorentzVector.h>
#include "Geometry.hh"
#include "globals.hh"
#include "LinearAlgebra.hh"
#include "TFitter.h"
#include "TMatrix.h"
#include "TMatrixD.h"
#include <Eigen/Dense>

#ifndef PHYSICS_DEFINE
#define PHYSICS_DEFINE

using Vector = vector::Vector;


namespace physics{

	//defines detector hit
	class sim_hit{
	public:

        template <typename tree_manager>
        sim_hit(tree_manager* tm, int n){
            index = n;
            x = (*(tm->sim_hit_x))[n];
            y = (*(tm->sim_hit_y))[n];
            z = (*(tm->sim_hit_z))[n];
            e = (*(tm->sim_hit_e))[n];
            t = (*(tm->sim_hit_t))[n];
            px = (*(tm->sim_hit_px))[n];
            py = (*(tm->sim_hit_py))[n];
            pz = (*(tm->sim_hit_pz))[n];
            particle_energy = (*(tm->sim_hit_particleEnergy))[n];
            pdg_id = (*(tm->sim_hit_particlePdgId))[n]; //[0];
            track_id = (*(tm->sim_hit_G4TrackId))[n]; //[0];
            particle_parent_trackid = (*(tm->sim_hit_G4ParentTrackId))[n]; //[0];
	    	det_id = detID((*(tm->sim_hit_center1))[n], (*(tm->sim_hit_center2))[n],
	    	(*(tm->sim_hit_bar_direction))[n], (*(tm->sim_hit_layer_direction))[n],
	    	(*(tm->sim_hit_layerID))[n]);
        }

		sim_hit(int index, double x, double y, double z, double t, double e){
			this->index = index;
			this->x = x;
			this->y = y;
			this->z = z;
			this->t = t;
			this->e = e;
		}

        void SetMomentum(Vector momentum){px = momentum.x; py = momentum.y; pz = momentum.z;}
        Vector GetParticleMomentum(){ return Vector(px, py, pz); }
		std::size_t index;
		double x;
		double y;
		double z;
		double t;
		double e;
        double px, py, pz; //momentum of particle which made the hit
        int track_id;
        int pdg_id;
        double particle_energy;
        double particle_parent_trackid;
		detID det_id;

	}; //sim



	class digi_hit{
	public:
		detID det_id;
		std::size_t index;
        int long_direction_index; //1 for odd layer, 0 for even layer
		double x, ex;
		double y, ey;
		double z, ez;
		double t;
		double e;
		double et = detector::time_resolution;
        double px, py, pz; // momentum of particle which made the hit
        double particle_mass;
        double particle_energy;
        int pdg;
        long int min_track_id = 9999999999;

        Vector PosVector(){ return Vector(x, y, z); }

		std::vector<sim_hit*> hits;

		void AddHit(sim_hit* hit){
            hits.push_back(hit);
            if (hit->track_id < min_track_id){
                min_track_id = hit->track_id;
                pdg = hit->pdg_id;
                particle_energy = hit->particle_energy;
                px = hit->px;
                py = hit->py;
                pz = hit->pz;
            }
        }

	}; //digi

}; // physics



#endif
