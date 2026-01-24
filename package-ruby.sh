rm -rf quickfix-ruby/lib
rm -rf quickfix-ruby/ext/quickfix/*.h
rm -rf quickfix-ruby/ext/quickfix/*.hpp
rm -rf quickfix-ruby/ext/quickfix/*.cpp
rm -rf quickfix-ruby/ext/quickfix/double-conversion
rm -rf quickfix-ruby/ext/quickfix/swig
rm -rf quickfix-ruby/test
rm -rf quickfix-ruby/spec

mkdir -p quickfix-ruby/lib
mkdir -p quickfix-ruby/ext/quickfix
mkdir -p quickfix-ruby/ext/quickfix/double-conversion
mkdir -p quickfix-ruby/ext/quickfix/swig
mkdir -p quickfix-ruby/test
mkdir -p quickfix-ruby/spec

cp quickfix/LICENSE quickfix-ruby/

cp quickfix/src/ruby/quickfix*.rb quickfix-ruby/lib
cp quickfix/src/C++/*.h quickfix-ruby/ext/quickfix
cp quickfix/src/C++/*.hpp quickfix-ruby/ext/quickfix
cp quickfix/src/C++/*.cpp quickfix-ruby/ext/quickfix
cp quickfix/src/C++/double-conversion/* quickfix-ruby/ext/quickfix/double-conversion
cp quickfix/src/ruby/QuickfixRuby.cpp quickfix-ruby/ext/quickfix
cp quickfix/src/ruby/QuickfixRuby.h quickfix-ruby/ext/quickfix
cp quickfix/src/swig/*.h quickfix-ruby/ext/quickfix/swig
cp quickfix/src/ruby/test/*TestCase.rb quickfix-ruby/test

cp quickfix/spec/FIX*.xml quickfix-ruby/spec

# Copy proper config files
if [ -f "quickfix/src/C++/config.h" ]; then
    cp quickfix/src/C++/config.h quickfix-ruby/ext/quickfix/
fi
if [ -f "quickfix/src/C++/config_unix.h" ]; then
    cp quickfix/src/C++/config_unix.h quickfix-ruby/ext/quickfix/
fi
touch quickfix-ruby/ext/quickfix/config_windows.h

pushd quickfix-ruby/test
for file in * ;
do
mv "$file" "test_$file"
done
popd

pushd quickfix-ruby

gem build quickfix.gemspec
