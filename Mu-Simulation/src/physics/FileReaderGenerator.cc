#include "physics/FileReaderGenerator.hh"

#include "physics/Particle.hh"
#include "analysis.hh"

#include <G4AutoLock.hh>

#include <string>
#include <cstddef>
#include <fstream>
#include <limits>
#include <ios>
#include <stdexcept>

namespace MATHUSLA { namespace MU { namespace Physics {

namespace {

G4Mutex mutex = G4MUTEX_INITIALIZER;

} // anonymous namespace

FileReaderGenerator::FileReaderGenerator(const std::string &name,
                                         const std::string &description)
    : Generator(name, description, {}) {
  GenerateCommands();
}

void FileReaderGenerator::GeneratePrimaryVertex(G4Event *event) {
  // std::size_t particle_parameters_index = _particle_parameters.size();
  // {
  //   G4AutoLock lock(mutex);
  //   particle_parameters_index = _event_counter;
  //   ++_event_counter;
  // }
  // AddParticle(_particle_parameters.at(particle_parameters_index), *event);
  std::size_t particle_parameters_index = _events.size();
  {
    G4AutoLock lock(mutex);
    particle_parameters_index = _event_counter;
    ++_event_counter;
  }

  auto & _event = _events[particle_parameters_index];

  for (std::size_t i{}; i < _event.size(); ++i) {
    // skip the primary particle
    if(i==0) continue; 
    auto particle = _event[i];
    AddParticle(particle, *event);
  }  
}

void FileReaderGenerator::SetNewValue(G4UIcommand *command, G4String value) {
  if (command == _ui_pathname) {
    std::ifstream input_stream(value);
    while (input_stream) {
      const auto next_char = input_stream.peek();
      if (next_char == std::ifstream::traits_type::eof()) {
              break;
      }
      if (next_char == ' ' || next_char == '\t' || next_char == '\r' || next_char == '\n') {
              input_stream.ignore();
              continue;
      }
      if (next_char == '#') {
              input_stream.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
              continue;}

      // Line start with "E":  make a new event.
      // This line contain the vertex information
      if (next_char == 'E') {
        _events.emplace_back();
        // Read the VERTEX information
        std::string temp1;
        int event_number;

        if ( ! (input_stream>>  temp1
                            >> _particle.index
                            >> _particle.id
                            >> _particle.x
                            >> _particle.y
                            >> _particle.z
                            >> _particle.px
                            >> _particle.py
                            >> _particle.pz
                            >> _particle.t)) {
          throw std::runtime_error("Unable to parse Vertex parameters");
        }  
        // Push the information of the primary vertex to list
        // If more particles are added, the primary vertex will not be generated. This information is saved for analysis
        // If this is the only particle in the event, it will be generated
        auto &new_event = _events.back();
        new_event.push_back(_particle);
        // Jump to the Next line
        input_stream.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        continue;
      } 
      // Line start with "P": Add particles to an existing event
      if (next_char == 'P') {
        auto &new_event = _events.back();
        new_event.emplace_back();
        auto &new_parameters = new_event.back();
        std::string temp1;
        if ( ! (input_stream>> temp1 
                            >> new_parameters.id
                            >> new_parameters.x
                            >> new_parameters.y
                            >> new_parameters.z
                            >> new_parameters.px
                            >> new_parameters.py
                            >> new_parameters.pz
                            >> new_parameters.t)) {throw std::runtime_error("Unable to parse particle parameters file (new)");}
        continue;
      }    

      
      // Keep this to be backward compatible              
      // "n" for new event. Make a new event if see a line "n"
      if (next_char == 'n') {
        _events.emplace_back();
        // Read the VERTEX information
        std::string temp1;
        int event_number;

        if ( ! (input_stream>>  temp1
                            >> _particle.index
                            >> _particle.id
                            >> _particle.x
                            >> _particle.y
                            >> _particle.z
                            >> _particle.px
                            >> _particle.py
                            >> _particle.pz)) {
          throw std::runtime_error("Unable to parse Vertex parameters file");
        }  
        // Push the information of the primary particle to list
        // (the primary particle will not be generated. This information is saved for analysis)
        auto &new_event = _events.back();
        new_event.push_back(_particle);
        // Jump to the Next line
        input_stream.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        continue;
      } 
      // append hits to this event
      else {
        auto &new_event = _events.back();
        new_event.emplace_back();
        auto &new_parameters = new_event.back();
        if ( ! (input_stream >> new_parameters.id
                            >> new_parameters.x
                            >> new_parameters.y
                            >> new_parameters.z
                            >> new_parameters.px
                            >> new_parameters.py
                            >> new_parameters.pz)) {
          throw std::runtime_error("Unable to parse particle parameters file");
        }   
      }
      

    }
    if ( ! input_stream) {
      throw std::runtime_error("Unable to read particle parameters file");
    }
  } else {
    Generator::SetNewValue(command, value);
  }
}

//__Get Last Event Data_________________________________________________________________________
// to be stored as GenParticles_xx in the root files
GenParticleVector FileReaderGenerator::GetLastEvent() const {
  GenParticleVector current_event = {};
  for (int i=0; i<_events[_event_counter-1].size(); i++){
    GenParticle x(_events[_event_counter-1][i]);
    current_event.push_back(x);
  }
  return current_event;
}

std::ostream &FileReaderGenerator::Print(std::ostream &os) const {
  os << "Generator Info:\n  "
     << "Name:        " << _name                           << "\n  "
     << "Description: " << _description                    << "\n  "
     << "Pathname:    " << _ui_pathname->GetCurrentValue() << "\n  ";
  return os;
}

const Analysis::SimSettingList FileReaderGenerator::GetSpecification() const {
  return Analysis::Settings(SimSettingPrefix,
    "",         _name,
    "_PATHNAME",  _ui_pathname->GetCurrentValue());
}

void FileReaderGenerator::GenerateCommands() {
  _ui_pathname = CreateCommand<Command::StringArg>("pathname", "Set pathname of particle parameters file.");
  _ui_pathname->SetParameterName("pathname", false, false);
  _ui_pathname->AvailableForStates(G4State_PreInit, G4State_Idle);
}

} } } // namespace MATHUSLA::MU::Physics
