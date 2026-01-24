#!/bin/bash

# Script to package QuickFix for Python
# Usage: ./package-python.sh [--test-pypi|--pypi|--build-only]
#   --build-only: Only build the package, don't upload
#   --test-pypi:  Build and upload to Test PyPI
#   --pypi:       Build and upload to production PyPI
#   (no args):    Build and upload to Test PyPI (default)

set -e

MODE="test-pypi"  # default mode

# Parse command line arguments
if [ "$1" == "--build-only" ]; then
    MODE="build-only"
elif [ "$1" == "--pypi" ]; then
    MODE="pypi"
elif [ "$1" == "--test-pypi" ]; then
    MODE="test-pypi"
elif [ -n "$1" ]; then
    echo "Usage: $0 [--test-pypi|--pypi|--build-only]"
    exit 1
fi

# Clean up old files
rm -rf quickfix-python/C++
rm -rf quickfix-python/swig
rm -rf quickfix-python/spec
rm -rf quickfix-python/quickfix*.py
rm -rf quickfix-python/doc
rm -rf quickfix-python/LICENSE

# Create directories
mkdir quickfix-python/C++
mkdir quickfix-python/swig
mkdir quickfix-python/spec

# Copy license
cp quickfix/LICENSE quickfix-python

# Copy Python modules
cp quickfix/src/python3/*.py quickfix-python

# Copy C++ source files
cp quickfix/src/C++/*.h quickfix-python/C++
cp quickfix/src/C++/*.hpp quickfix-python/C++
cp quickfix/src/C++/*.cpp quickfix-python/C++
cp -R quickfix/src/C++/double-conversion quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.cpp quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.h quickfix-python/C++

# Copy FIX specification files
cp quickfix/src/swig/*.h quickfix-python/swig
cp quickfix/spec/FIX*.xml quickfix-python/spec

# Create config files
if [ -f "quickfix/src/C++/config.h" ]; then
    cp quickfix/src/C++/config.h quickfix-python/C++/config.h
fi
if [ -f "quickfix/src/C++/config_unix.h" ]; then
    cp quickfix/src/C++/config_unix.h quickfix-python/C++/config_unix.h
fi
touch quickfix-python/C++/config_windows.h
rm -f quickfix-python/C++/stdafx.*

# Build the package
pushd quickfix-python
python3 setup.py sdist
popd

echo ""
echo "=== Package Build Complete ==="
echo ""

# Upload based on mode
if [ "$MODE" == "build-only" ]; then
    echo "Package built successfully. Distribution files are in quickfix-python/dist/"
    echo ""
    echo "To upload manually:"
    echo "  Test PyPI: twine upload --repository testpypi quickfix-python/dist/*"
    echo "  Production: twine upload quickfix-python/dist/*"
elif [ "$MODE" == "test-pypi" ]; then
    echo "Uploading to Test PyPI..."
    pushd quickfix-python
    PYTHONWARNINGS="ignore" twine upload --repository testpypi dist/*
    popd
    echo ""
    echo "Package uploaded to Test PyPI!"
    echo "View it at: https://test.pypi.org/project/quickfix/"
    echo ""
    echo "To validate, run: ./validate-test-pypi.sh"
elif [ "$MODE" == "pypi" ]; then
    echo "Uploading to Production PyPI..."
    pushd quickfix-python
    PYTHONWARNINGS="ignore" twine upload dist/*
    popd
    echo ""
    echo "Package uploaded to Production PyPI!"
    echo "View it at: https://pypi.org/project/quickfix/"
fi
# PYTHONWARNINGS="ignore" twine upload --repository testpypi dist/*
