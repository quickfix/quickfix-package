#!/bin/bash
set -e
if [ -z "$1" ]
  then
    echo "No argument supplied for python executable path"
    exit 1
fi
echo "Installing QuickFix for Python: $1"

rm -rf quickfix

git clone --depth 1 https://github.com/quickfix/quickfix.git
rm -rf quickfix/.git

#Clean up the build environment
rm -rf quickfix-python/C++
rm -rf quickfix-python/spec
rm -rf quickfix-python/quickfix*.py
rm -rf quickfix-python/doc
rm -rf quickfix-python/LICENSE

mkdir quickfix-python/C++
mkdir quickfix-python/spec

#Move the source into the folder at hand
cp quickfix/LICENSE quickfix-python

cp quickfix/src/python3/*.py quickfix-python
cp quickfix/src/C++/*.h quickfix-python/C++
cp quickfix/src/C++/*.hpp quickfix-python/C++
cp quickfix/src/C++/*.cpp quickfix-python/C++
cp -R quickfix/src/C++/double-conversion quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.cpp quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.h quickfix-python/C++

cp quickfix/spec/FIX*.xml quickfix-python/spec

#Satisfy empty headers
touch quickfix-python/C++/config.h
touch quickfix-python/C++/config_windows.h
touch quickfix-python/C++/Allocator.h
rm -f quickfix-python/C++/stdafx.*

#Do the build for the active python
pushd quickfix-python
	CFLAGS="-I \"$(pwd)/C++\"" $1 setup.py install
popd
