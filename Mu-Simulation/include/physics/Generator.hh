#ifndef MU__PHYSICS_GENERATOR_HH
#define MU__PHYSICS_GENERATOR_HH
#pragma once

#include <G4Event.hh>
#include <G4PrimaryVertex.hh>
#include <G4PrimaryParticle.hh>

#include "analysis.hh"
#include "ui.hh"

#include "physics/Particle.hh"

namespace MATHUSLA { namespace MU {

namespace Physics { ////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------------------

//__Default Vertex for IP_______________________________________________________________________
G4PrimaryVertex* DefaultVertex();
//----------------------------------------------------------------------------------------------

//__Default Particle Generator__________________________________________________________________
class Generator : public G4UImessenger {
public:
  Generator(const std::string& name,
            const std::string& description,
            const Particle& particle);

  virtual ~Generator() = default;

  virtual void GeneratePrimaryVertex(G4Event* event);
  virtual GenParticleVector GetLastEvent() const;
  virtual void SetNewValue(G4UIcommand* command,
                           G4String value);
  virtual std::ostream& Print(std::ostream& os=std::cout) const;
  virtual const Analysis::SimSettingList GetSpecification() const;
  virtual const std::vector<std::vector<double>> ExtraDetails() const;

  const Particle& particle() const { return _particle; }
  const std::string& name() const { return _name; }
  const std::string& description() const { return _description; }

  static const std::string MessengerDirectory;
  static const std::string SimSettingPrefix;

protected:
  Generator(const std::string& name,
            const std::string& description);
  virtual void GenerateCommands();

  std::string _name, _description;
  Particle _particle;
  Command::IntegerArg*         _ui_id;
  Command::DoubleUnitArg*      _ui_pT;
  Command::DoubleArg*          _ui_eta;
  Command::DoubleUnitArg*      _ui_phi;
  Command::DoubleUnitArg*      _ui_ke;
  Command::ThreeVectorUnitArg* _ui_p;
  Command::ThreeVectorArg*     _ui_p_unit;
  Command::DoubleUnitArg*      _ui_p_mag;
  Command::DoubleUnitArg*      _ui_t0;
  Command::ThreeVectorUnitArg* _ui_vertex;
};
//----------------------------------------------------------------------------------------------

//__Default Range Particle Generator____________________________________________________________
class RangeGenerator : public Generator {
public:
  RangeGenerator(const std::string& name,
                 const std::string& description,
                 const Particle& particle);
  RangeGenerator(const std::string& name,
                 const std::string& description,
                 const Particle& min,
                 const Particle& max);

  virtual ~RangeGenerator() = default;

  virtual void GeneratePrimaryVertex(G4Event* event);
  virtual GenParticleVector GetLastEvent() const;
  virtual void SetNewValue(G4UIcommand* command,
                           G4String value);
  virtual std::ostream& Print(std::ostream& os=std::cout) const;
  virtual const Analysis::SimSettingList GetSpecification() const;

  const Particle& min() const { return _min; }
  const Particle& max() const { return _max; }

protected:
  virtual void GenerateCommands();

  Particle _min, _max;
  bool _using_range_ke;
  Command::DoubleUnitArg* _ui_pT_min;
  Command::DoubleUnitArg* _ui_pT_max;
  Command::DoubleArg*     _ui_eta_min;
  Command::DoubleArg*     _ui_eta_max;
  Command::DoubleUnitArg* _ui_phi_min;
  Command::DoubleUnitArg* _ui_phi_max;
  Command::DoubleUnitArg* _ui_ke_min;
  Command::DoubleUnitArg* _ui_ke_max;
};
//----------------------------------------------------------------------------------------------

//__Default Polar Particle Generator____________________________________________________________
class PolarGenerator : public Generator {
public:

  PolarGenerator(const std::string& name,
                 const std::string& description,
                 const Particle& particle);

  virtual ~PolarGenerator() = default;

  virtual void GeneratePrimaryVertex(G4Event* event);
  virtual void SetNewValue(G4UIcommand* command,
                           G4String value);
  virtual std::ostream& Print(std::ostream& os=std::cout) const;
  virtual const Analysis::SimSettingList GetSpecification() const;


protected:

  virtual void GenerateCommands();

  double _azimuth_min, _azimuth_max, _polar_min, _polar_max, _polar, _e;

  Command::DoubleUnitArg*      _ui_azimuth_min;
  Command::DoubleUnitArg*      _ui_azimuth_max;
  Command::DoubleUnitArg*      _ui_polar_min;
  Command::DoubleUnitArg*      _ui_polar_max;
  Command::DoubleUnitArg*      _ui_polar;
  Command::DoubleUnitArg*      _ui_e;
};
//----------------------------------------------------------------------------------------------

//__Stream Operator for Generators______________________________________________________________
inline std::ostream& operator<<(std::ostream& os,
                                const Generator& generator) {
  return generator.Print(os);
}
//----------------------------------------------------------------------------------------------

} /* namespace Physics */ //////////////////////////////////////////////////////////////////////

} } /* namespace MATHUSLA::MU */

#endif /* MU__PHYSICS_GENERATOR_HH */
