require 'mkmf'
dir_config("quickfix", ["."], ".")
CONFIG["CC"] = ENV['CXX']
CONFIG["CXXFLAGS"] = '-std=c++0x'
CONFIG["LIBS"] += ENV['LIBS'] if ENV['LIBS'] != nil

if( ENV['CXX'] != nil )
  CONFIG["LDSHARED"].gsub!("gcc", ENV['CXX']) 
  CONFIG["LDSHARED"].gsub!("cc", ENV['CXX'])
end

create_makefile("quickfix")
