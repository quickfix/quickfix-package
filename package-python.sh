#!/usr/bin/env bash
#
# Compile and install Python QuickFIX package. Default behavior uploads to PyPI.
# Use -d optional argument for local installation only
#
# Usage:
# bash package-python.sh [-d]

PRODUCTION=0

while getopts "d" opt; do
    case $opt in
    d)
        PRODUCTION=1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

rm -rf quickfix-python/C++
rm -rf quickfix-python/spec
rm -rf quickfix-python/quickfix*.py
rm -rf quickfix-python/doc
rm -rf quickfix-python/LICENSE

mkdir quickfix-python/C++
mkdir quickfix-python/spec

cp quickfix/LICENSE quickfix-python

cp quickfix/src/python/*.py quickfix-python
cp quickfix/src/C++/*.h quickfix-python/C++
cp quickfix/src/C++/*.hpp quickfix-python/C++
cp quickfix/src/C++/*.cpp quickfix-python/C++
cp quickfix/src/python/QuickfixPython.cpp quickfix-python/C++
cp quickfix/src/python/QuickfixPython.h quickfix-python/C++

cp quickfix/spec/FIX*.xml quickfix-python/spec

touch quickfix-python/C++/config.h
touch quickfix-python/C++/config_windows.h
rm -f quickfix-python/C++/stdafx.*

pushd quickfix-python

if [ "$PRODUCTION" -eq "0" ]; then
    python setup.py sdist upload -r pypi
else
    python setup.py install
fi
