
#include "physics/Generator.hh"

#include <cmath>
#include <limits>
#include <ostream>

#include <Randomize.hh>
#include <G4ParticleTable.hh>

#include "physics/Units.hh"

#include "util/string.hh"

namespace MATHUSLA { namespace MU {

    namespace Physics { ////////////////////////////////////////////////////////////////////////////

PolarGenerator::PolarGenerator(const std::string &name,
                               const std::string &description,
                               const Particle& particle)
    : Generator(name, description, particle) {
  GenerateCommands();
}

//__PolarGenerate UI Commands________________________________________________________________________
void PolarGenerator::GenerateCommands() {
  _ui_azimuth_min = CreateCommand<Command::DoubleUnitArg>("azimuth_min", "Set Minimum Azimuthal Angle.");
  _ui_azimuth_min->SetParameterName("azimuth_min", false, false);
  _ui_azimuth_min->SetDefaultUnit("deg");
  _ui_azimuth_min->SetUnitCandidates("degree deg radian rad milliradian mrad");
  _ui_azimuth_min->AvailableForStates(G4State_PreInit, G4State_Idle);

  _ui_azimuth_max = CreateCommand<Command::DoubleUnitArg>("azimuth_max", "Set Maximum Azimuthal Angle.");
  _ui_azimuth_max->SetParameterName("azimuth_max", false, false);
  _ui_azimuth_max->SetDefaultUnit("deg");
  _ui_azimuth_max->SetUnitCandidates("degree deg radian rad milliradian mrad");
  _ui_azimuth_max->AvailableForStates(G4State_PreInit, G4State_Idle);

  _ui_polar_min = CreateCommand<Command::DoubleUnitArg>("polar_min", "Set Minimum Polar Angle.");
  _ui_polar_min->SetParameterName("polar_min", false, false);
  _ui_polar_min->SetDefaultUnit("deg");
  _ui_polar_min->SetUnitCandidates("degree deg radian rad milliradian mrad");
  _ui_polar_min->AvailableForStates(G4State_PreInit, G4State_Idle);

  _ui_polar_max = CreateCommand<Command::DoubleUnitArg>("polar_max", "Set Maximum Polar Angle.");
  _ui_polar_max->SetParameterName("polar_max", false, false);
  _ui_polar_max->SetDefaultUnit("deg");
  _ui_polar_max->SetUnitCandidates("degree deg radian rad milliradian mrad");
  _ui_polar_max->AvailableForStates(G4State_PreInit, G4State_Idle);

  _ui_polar = CreateCommand<Command::DoubleUnitArg>("polar", "Set Polar Angle.");
  _ui_polar->SetParameterName("polar", false, false);
  _ui_polar->SetDefaultUnit("deg");
  _ui_polar->SetUnitCandidates("degree deg radian rad milliradian mrad");
  _ui_polar->AvailableForStates(G4State_PreInit, G4State_Idle);

  _ui_e = CreateCommand<Command::DoubleUnitArg>("e", "Set Energy.");
  _ui_e->SetParameterName("e", false, false);
  _ui_e->SetRange("e >= 0");
  _ui_e->SetDefaultUnit("GeV");
  _ui_e->SetUnitCandidates("eV keV MeV GeV");
  _ui_e->AvailableForStates(G4State_PreInit, G4State_Idle);
}
//----------------------------------------------------------------------------------------------

//__PolarGenerate Initial Particles_____________________________________________________________
void PolarGenerator::GeneratePrimaryVertex(G4Event* event) {
    if (_polar_max > 0) {
        const auto azimuth = G4RandFlat::shoot(_azimuth_min, _azimuth_max);
        const auto polar = G4RandFlat::shoot(_polar_min, _polar_max);
        const auto momentum_mag = std::sqrt(std::pow(_e, 2) - std::pow(GetParticleMass(_particle.id), 2));
        _particle.px = momentum_mag * std::sin(polar) * std::cos(azimuth);
        _particle.py = momentum_mag * std::sin(polar) * std::sin(azimuth);
        _particle.pz = momentum_mag * std::cos(polar);
    } else {
        const auto azimuth = G4RandFlat::shoot(_azimuth_min, _azimuth_max);
        const auto momentum_mag = std::sqrt(std::pow(_e, 2) - std::pow(GetParticleMass(_particle.id), 2));
        _particle.px = momentum_mag * std::sin(_polar) * std::cos(azimuth);
        _particle.py = momentum_mag * std::sin(_polar) * std::sin(azimuth);
        _particle.pz = momentum_mag * std::cos(_polar);
    }

    AddParticle(_particle, *event);
}
//----------------------------------------------------------------------------------------------

// __PolarGenerator Messenger Set Value_________________________________________________________
void PolarGenerator::SetNewValue(G4UIcommand* command,
                            G4String value) {
  if (command == _ui_id) {
    _particle.id = _ui_id->GetNewIntValue(value);
  } else if (command == _ui_azimuth_min) {
    _azimuth_min = _ui_azimuth_min->GetNewDoubleValue(value);
  }  else if (command == _ui_azimuth_max) {
    _azimuth_max = _ui_azimuth_max->GetNewDoubleValue(value);
  } else if (command == _ui_polar_min) {
    _polar_min = _ui_polar_min->GetNewDoubleValue(value);
  } else if (command == _ui_polar_max) {
    _polar_max = _ui_polar_max->GetNewDoubleValue(value);
  } else if (command == _ui_polar) {
    _polar = _ui_polar->GetNewDoubleValue(value);
  } else if (command == _ui_e) {
    _e = _ui_e->GetNewDoubleValue(value);
  } else if (command == _ui_vertex) {
    _particle.set_vertex(_ui_vertex->GetNew3VectorValue(value));
  }
}

//----------------------------------------------------------------------------------------------

//__PolarGenerator Information String___________________________________________________________
std::ostream& PolarGenerator::Print(std::ostream& os) const {
  return os << "PolarGenerator Info:\n  "
            << "Name:        "  << _name                                     << "\n  "
            << "Description: "  << _description                              << "\n  "
            << "Particle ID: "  << _particle.id                              << "\n  "
            << "Energy:      "  << G4BestUnit(_e, "Energy")                  << "\n  ";
         if (_polar_max > 0) {
			 os << "polar min: "      << G4BestUnit(_polar_min,     "Angle") << "\n  "
				<< "polar max: "      << G4BestUnit(_polar_max,     "Angle") << "\n  "
                << "azimuth min: "    << G4BestUnit(_azimuth_min,   "Angle") << "\n  "
				<< "azimuth max: "    << G4BestUnit(_azimuth_min,   "Angle") << "\n  ";
		 } else {
             os << "polar: "          << G4BestUnit(_polar,         "Angle") << "\n  "
                << "azimuth min: "    << G4BestUnit(_azimuth_min,   "Angle") << "\n  "
                << "azimuth max: "    << G4BestUnit(_azimuth_min,   "Angle") << "\n  ";
		 }
   
		 os << "vertex:      (" << G4BestUnit(_particle.t, "Time")           << ", "
		                        << G4BestUnit(_particle.x, "Length")         << ", "
		                        << G4BestUnit(_particle.y, "Length")         << ", "
		                        << G4BestUnit(_particle.z, "Length")         << ")\n";
}
//----------------------------------------------------------------------------------------------

//__PolarGenerator Specifications_______________________________________________________________
const Analysis::SimSettingList PolarGenerator::GetSpecification() const {
	if (_polar_max > 0) {
		return Analysis::Settings(SimSettingPrefix,
								  "",        _name,
								  "_PDG_ID", std::to_string(_particle.id),
								  "_ENERGY", std::to_string(_e / Units::Energy) + " "  + Units::EnergyString,
                                  "_POLAR_MIN",   std::to_string(_polar_min   / Units::Angle) + " " + Units::AngleString,
                                  "_POLAR_MAX",   std::to_string(_polar_max   / Units::Angle) + " " + Units::AngleString,
								  "_AZIMUTH_MIN", std::to_string(_azimuth_min / Units::Angle) + " " + Units::AngleString,
								  "_AZIMUTH_MAX", std::to_string(_azimuth_max / Units::Angle) + " " + Units::AngleString,
                                  "_VERTEX", "(" + std::to_string(_particle.t / Units::Time)      + ", "
								  + std::to_string(_particle.x / Units::Length)    + ", "
								  + std::to_string(_particle.y / Units::Length)    + ", "
								  + std::to_string(_particle.z / Units::Length)    + ")");
	} else {
		return Analysis::Settings(SimSettingPrefix,
								  "",        _name,
								  "_PDG_ID", std::to_string(_particle.id),
								  "_ENERGY", std::to_string(_e / Units::Energy) + " "  + Units::EnergyString,
								  "_AZIMUTH_MIN", std::to_string(_azimuth_min / Units::Angle) + " " + Units::AngleString,
								  "_AZIMUTH_MAX", std::to_string(_azimuth_max / Units::Angle) + " " + Units::AngleString,
								  "_POLAR",       std::to_string(_polar       / Units::Angle) + " " + Units::AngleString,
								  "_VERTEX", "(" + std::to_string(_particle.t / Units::Time)      + ", "
								  + std::to_string(_particle.x / Units::Length)    + ", "
								  + std::to_string(_particle.y / Units::Length)    + ", "
								  + std::to_string(_particle.z / Units::Length)    + ")");
	}
}
//----------------------------------------------------------------------------------------------

} /* namespace Physics */ //////////////////////////////////////////////////////////////////////

} } /* namespace MATHUSLA::MU */
