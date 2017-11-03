#!/usr/bin/env bash

rm -rf quickfix-python3/C++
rm -rf quickfix-python3/spec
rm -rf quickfix-python3/quickfix*.py
rm -rf quickfix-python3/doc
rm -rf quickfix-python3/LICENSE

mkdir quickfix-python3/C++
mkdir quickfix-python3/spec

cp quickfix/LICENSE quickfix-python3

cp quickfix/src/python3/*.py quickfix-python3
cp quickfix/src/C++/*.h quickfix-python3/C++
cp quickfix/src/C++/*.hpp quickfix-python3/C++
cp quickfix/src/C++/*.cpp quickfix-python3/C++
cp -r quickfix/src/C++/double-conversion quickfix-python3/C++
cp quickfix/src/python3/QuickfixPython.cpp quickfix-python3/C++
cp quickfix/src/python3/QuickfixPython.h quickfix-python3/C++

cp quickfix/spec/FIX*.xml quickfix-python3/spec

touch quickfix-python3/C++/config.h
touch quickfix-python3/C++/config_windows.h
rm -f quickfix-python3/C++/stdafx.*

pushd quickfix-python3

python3 setup.py sdist upload -r pypi
