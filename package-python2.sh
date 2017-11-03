#!/usr/bin/env bash

rm -rf quickfix-python2/C++
rm -rf quickfix-python2/spec
rm -rf quickfix-python2/quickfix*.py
rm -rf quickfix-python2/doc
rm -rf quickfix-python2/LICENSE

mkdir quickfix-python2/C++
mkdir quickfix-python2/spec

cp quickfix/LICENSE quickfix-python2

cp quickfix/src/python2/*.py quickfix-python2
cp quickfix/src/C++/*.h quickfix-python2/C++
cp quickfix/src/C++/*.hpp quickfix-python2/C++
cp quickfix/src/C++/*.cpp quickfix-python2/C++
cp -r quickfix/src/C++/double-conversion quickfix-python2/C++
cp quickfix/src/python2/QuickfixPython.cpp quickfix-python2/C++
cp quickfix/src/python2/QuickfixPython.h quickfix-python2/C++

cp quickfix/spec/FIX*.xml quickfix-python2/spec

touch quickfix-python2/C++/config.h
touch quickfix-python2/C++/config_windows.h
rm -f quickfix-python2/C++/stdafx.*

pushd quickfix-python2

python2 setup.py sdist upload -r pypi
