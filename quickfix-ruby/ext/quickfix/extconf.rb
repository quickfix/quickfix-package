require 'mkmf'

# Get all C++ source files using glob pattern, just like Python setup.py
$srcs = Dir.glob("*.cpp").reject { |f| f == "extconf.rb" }

dir_config("quickfix", ["."], ".")
CONFIG["CC"] = ENV['CXX'] || "g++"

# Add C++ specific compile flags, matching Python setup.py
# Include both current directory and swig directory like Python does
$CXXFLAGS += " -std=c++17 -Wno-deprecated -Wno-unused-variable -Wno-unused-label -Wno-deprecated-declarations -Wno-maybe-uninitialized -D__cpp_noexcept_function_type -I. -I./swig"
CONFIG["LIBS"] += ENV['LIBS'] if ENV['LIBS'] != nil

if( ENV['CXX'] != nil )
  CONFIG["LDSHARED"].gsub!("gcc", ENV['CXX']) 
  CONFIG["LDSHARED"].gsub!("cc", ENV['CXX'])
end

create_makefile("quickfix")
