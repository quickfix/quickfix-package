#!/bin/bash

# Script to validate QuickFix Python package from Test PyPI
# This script creates a fresh virtual environment, installs the package,
# and runs basic validation tests
# Usage: ./validate-test-pypi.sh [version]

set -e

VERSION=${1:-""}
VENV_DIR="test_env_validation"

echo "=== Validating QuickFix Package from Test PyPI ==="
echo ""

# Clean up any existing test environment
if [ -d "$VENV_DIR" ]; then
    echo "Removing existing test environment..."
    rm -rf "$VENV_DIR"
fi

# Create a fresh virtual environment
echo "Creating fresh virtual environment..."
python3 -m venv "$VENV_DIR"

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo ""
echo "Upgrading pip..."
pip install --upgrade pip

# Install the package from Test PyPI
echo ""
if [ -n "$VERSION" ]; then
    echo "Installing quickfix==$VERSION from Test PyPI..."
    pip install --index-url https://test.pypi.org/simple/ --no-deps quickfix==$VERSION
else
    echo "Installing latest quickfix from Test PyPI..."
    pip install --index-url https://test.pypi.org/simple/ --no-deps quickfix
fi

# Run validation tests
echo ""
echo "=== Running Validation Tests ==="
echo ""

# Test 1: Check if module can be imported
echo "Test 1: Importing quickfix module..."
python3 -c "import quickfix; print('✓ Successfully imported quickfix')" || {
    echo "✗ Failed to import quickfix"
    deactivate
    exit 1
}

# Test 2: Check version
echo ""
echo "Test 2: Checking package version..."
INSTALLED_VERSION=$(python3 -c "import quickfix; import pkg_resources; print(pkg_resources.get_distribution('quickfix').version)")
echo "✓ Installed version: $INSTALLED_VERSION"

# Test 3: Check if core classes are available
echo ""
echo "Test 3: Checking core classes..."
python3 << 'EOF'
import quickfix

# Check for key classes
classes_to_check = [
    'Session',
    'Application',
    'Message',
    'SessionSettings',
    'FileStoreFactory',
    'ScreenLogFactory',
    'SocketInitiator',
    'SocketAcceptor',
    'SessionID',
    'Dictionary',
    'DataDictionary',
]

all_passed = True
for class_name in classes_to_check:
    if hasattr(quickfix, class_name):
        print(f"  ✓ {class_name} is available")
    else:
        print(f"  ✗ {class_name} is NOT available")
        all_passed = False

if all_passed:
    print("\n✓ All core classes are available")
else:
    print("\n✗ Some core classes are missing")
    exit(1)
EOF

if [ $? -ne 0 ]; then
    deactivate
    exit 1
fi

# Test 4: Check if FIX specification files are installed
echo ""
echo "Test 4: Checking FIX specification files..."
python3 << 'EOF'
import quickfix
import os
import sys

# Find the package installation directory
package_path = quickfix.__file__
package_dir = os.path.dirname(package_path)
site_packages = os.path.dirname(package_dir)

# Look for spec files in common locations
spec_locations = [
    os.path.join(site_packages, 'share', 'quickfix'),
    os.path.join(sys.prefix, 'share', 'quickfix'),
]

spec_files = []
for location in spec_locations:
    if os.path.exists(location):
        spec_files = [f for f in os.listdir(location) if f.startswith('FIX') and f.endswith('.xml')]
        if spec_files:
            print(f"  ✓ Found {len(spec_files)} FIX spec files in {location}")
            for spec in sorted(spec_files)[:5]:  # Show first 5
                print(f"    - {spec}")
            if len(spec_files) > 5:
                print(f"    ... and {len(spec_files) - 5} more")
            break

if not spec_files:
    print("  ⚠ Warning: FIX specification files not found in expected locations")
    print("    This may cause issues when using the library")
else:
    print(f"\n✓ FIX specification files are installed")
EOF

# Test 5: Create a basic FIX message
echo ""
echo "Test 5: Creating a basic FIX message..."
python3 << 'EOF'
import quickfix as fix
import quickfix42 as fix42

# Create a simple message using version-specific class
msg = fix42.Message()
msg.setField(fix.Symbol("TEST"))

print(f"  ✓ Created FIX 4.2 message")
print(f"    Message preview: {msg.toString()[:60]}...")
print("\n✓ Basic FIX message creation successful")
EOF

if [ $? -ne 0 ]; then
    echo "✗ Failed to create FIX message"
    deactivate
    exit 1
fi

# Deactivate and clean up
deactivate

echo ""
echo "=== Validation Complete ==="
echo ""
echo "✓ All validation tests passed!"
echo ""
echo "The package from Test PyPI is working correctly."
echo ""
echo "To clean up the test environment, run:"
echo "  rm -rf $VENV_DIR"
