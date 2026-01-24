#!/bin/bash

# Script to publish QuickFix Python package to Test PyPI
# Usage: ./publish-test-pypi.sh

set -e

echo "=== Publishing QuickFix Python Package to Test PyPI ==="
echo ""

# Check if twine is installed
if ! command -v twine &> /dev/null; then
    echo "Error: twine is not installed."
    echo "Install it with: pip install twine"
    exit 1
fi

# Navigate to the quickfix-python directory
if [ ! -d "quickfix-python" ]; then
    echo "Error: quickfix-python directory not found"
    echo "Please run package-python.sh first to prepare the package"
    exit 1
fi

cd quickfix-python

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf build dist *.egg-info

# Build the package
echo ""
echo "Building package..."
python3 setup.py sdist

# Check if dist directory was created
if [ ! -d "dist" ]; then
    echo "Error: Build failed - dist directory not created"
    exit 1
fi

# Check the distribution
echo ""
echo "Checking package with twine..."
twine check dist/*

# Upload to Test PyPI
echo ""
echo "Uploading to Test PyPI..."
echo "You will be prompted for your Test PyPI credentials"
echo "(Use API token if configured: username=__token__, password=<your-token>)"
echo ""

PYTHONWARNINGS="ignore" twine upload --verbose --repository testpypi dist/*

echo ""
echo "=== Upload Complete ==="
echo ""
echo "Package uploaded to Test PyPI!"
echo "View it at: https://test.pypi.org/project/quickfix/"
echo ""
echo "To validate the package, run: ./validate-test-pypi.sh"
