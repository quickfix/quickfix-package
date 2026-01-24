#!/bin/bash

# Script to validate locally built QuickFix Python package
# This script tests the package before uploading to any PyPI repository
# Usage: ./validate-local-build.sh [path-to-dist-file]

set -e

DIST_FILE=${1:-""}
VENV_DIR="test_env_local"

echo "=== Validating Locally Built QuickFix Package ==="
echo ""

# Find the distribution file if not specified
if [ -z "$DIST_FILE" ]; then
    if [ ! -d "quickfix-python/dist" ]; then
        echo "Error: quickfix-python/dist directory not found"
        echo "Please run './package-python.sh --build-only' first"
        exit 1
    fi

    # Find the most recent .tar.gz file
    DIST_FILE=$(ls -t quickfix-python/dist/*.tar.gz 2>/dev/null | head -1)

    if [ -z "$DIST_FILE" ]; then
        echo "Error: No distribution files found in quickfix-python/dist/"
        echo "Please run './package-python.sh --build-only' first"
        exit 1
    fi

    echo "Found distribution file: $DIST_FILE"
else
    if [ ! -f "$DIST_FILE" ]; then
        echo "Error: Distribution file not found: $DIST_FILE"
        exit 1
    fi
fi

# Get absolute path
DIST_FILE=$(cd "$(dirname "$DIST_FILE")" && pwd)/$(basename "$DIST_FILE")
echo "Testing package: $DIST_FILE"
echo ""

# Check the distribution with twine (if available)
if command -v twine &> /dev/null; then
    echo "Running twine check..."
    twine check "$DIST_FILE"
    echo "✓ Twine check passed"
    echo ""
else
    echo "⚠ Warning: twine not installed, skipping package validation"
    echo "  Install with: pip install twine"
    echo ""
fi

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
pip install --upgrade pip --quiet

# Install the local package
echo ""
echo "Installing package from local file..."
pip install --verbose --verbose --verbose "$DIST_FILE"

# Extract version from the installed package
INSTALLED_VERSION=$(python3 -c "import pkg_resources; print(pkg_resources.get_distribution('quickfix').version)" 2>/dev/null || echo "unknown")
echo "✓ Installed version: $INSTALLED_VERSION"

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

# Test 2: Check if all FIX version modules can be imported
echo ""
echo "Test 2: Importing FIX version modules..."
python3 << 'EOF'
import sys

modules = [
    'quickfix',
    'quickfixt11',
    'quickfix40',
    'quickfix41',
    'quickfix42',
    'quickfix43',
    'quickfix44',
    'quickfix50',
    'quickfix50sp1',
    'quickfix50sp2',
]

all_passed = True
for module_name in modules:
    try:
        __import__(module_name)
        print(f"  ✓ {module_name}")
    except ImportError as e:
        print(f"  ✗ {module_name} - {e}")
        all_passed = False

if all_passed:
    print("\n✓ All FIX version modules imported successfully")
else:
    print("\n✗ Some modules failed to import")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    deactivate
    exit 1
fi

# Test 3: Check if core classes are available
echo ""
echo "Test 3: Checking core classes..."
python3 << 'EOF'
import quickfix

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
    'MessageStore',
    'MessageStoreFactory',
]

all_passed = True
for class_name in classes_to_check:
    if hasattr(quickfix, class_name):
        print(f"  ✓ {class_name}")
    else:
        print(f"  ✗ {class_name} NOT FOUND")
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

package_path = quickfix.__file__
package_dir = os.path.dirname(package_path)
site_packages = os.path.dirname(package_dir)

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
            for spec in sorted(spec_files):
                print(f"    - {spec}")
            break

if not spec_files:
    print("  ⚠ Warning: FIX specification files not found")
    print("    This may cause issues when using the library")
else:
    print(f"\n✓ FIX specification files are installed")
EOF

# Test 5: Create messages for multiple FIX versions
echo ""
echo "Test 5: Creating FIX messages for different versions..."
python3 << 'EOF'
import quickfix as fix
import quickfix42 as fix42
import quickfix44 as fix44
import quickfix50 as fix50

# Test FIX 4.2 - use version-specific Message class
msg42 = fix42.Message()
msg42.setField(fix.Symbol("AAPL"))
print(f"  ✓ FIX 4.2 message created")

# Test FIX 4.4 - use specific message type
msg44 = fix44.NewOrderSingle()
msg44.setField(fix.ClOrdID("ORDER456"))
msg44.setField(fix.Symbol("MSFT"))
msg44.setField(fix.Side(fix.Side_BUY))
msg44.setField(fix.TransactTime())
msg44.setField(fix.OrdType(fix.OrdType_MARKET))
print(f"  ✓ FIX 4.4 NewOrderSingle message created")

# Test FIX 5.0
msg50 = fix50.Message()
msg50.setField(fix.Symbol("GOOG"))
print(f"  ✓ FIX 5.0 message created")

print("\n✓ Successfully created messages for multiple FIX versions")
EOF

if [ $? -ne 0 ]; then
    echo "✗ Failed to create FIX messages"
    deactivate
    exit 1
fi

# Test 6: Test SessionSettings with a config
echo ""
echo "Test 6: Testing SessionSettings..."
python3 << 'EOF'
import quickfix
import tempfile
import os

# Create a minimal FIX config
config_content = """[DEFAULT]
ConnectionType=initiator
ReconnectInterval=60
FileStorePath=store
FileLogPath=log

[SESSION]
BeginString=FIX.4.2
SenderCompID=SENDER
TargetCompID=TARGET
StartTime=00:00:00
EndTime=00:00:00
HeartBtInt=30
"""

# Write to temp file
with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.cfg') as f:
    f.write(config_content)
    config_file = f.name

try:
    # Load settings
    settings = quickfix.SessionSettings(config_file)
    print(f"  ✓ SessionSettings loaded from config file")

    # Access a setting
    default_dict = settings.get()
    connection_type = default_dict.getString('ConnectionType')
    print(f"  ✓ Read setting: ConnectionType = {connection_type}")

    print("\n✓ SessionSettings test passed")
finally:
    os.unlink(config_file)
EOF

if [ $? -ne 0 ]; then
    echo "✗ SessionSettings test failed"
    deactivate
    exit 1
fi

# Deactivate virtual environment
deactivate

echo ""
echo "=== Validation Complete ==="
echo ""
echo "✓ All validation tests passed!"
echo ""
echo "Package file: $DIST_FILE"
echo "Package version: $INSTALLED_VERSION"
echo ""
echo "The locally built package is working correctly and is ready to upload."
echo ""
echo "Next steps:"
echo "  - Upload to Test PyPI: ./publish-test-pypi.sh"
echo "  - Or upload to Production: ./package-python.sh --pypi"
echo ""
echo "To clean up the test environment, run:"
echo "  rm -rf $VENV_DIR"
