#!/bin/bash

# Script to inspect the contents of a built Python distribution package
# Usage: ./inspect-package.sh [path-to-dist-file]

set -e

DIST_FILE=${1:-""}

echo "=== Inspecting QuickFix Python Package Contents ==="
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

echo "Package: $DIST_FILE"
echo ""

# Extract package name and version
BASENAME=$(basename "$DIST_FILE" .tar.gz)
echo "Package name: $BASENAME"
echo ""

# Show package size
SIZE=$(ls -lh "$DIST_FILE" | awk '{print $5}')
echo "Package size: $SIZE"
echo ""

# List contents
echo "=== Package Contents ==="
echo ""

# Create temp directory for inspection
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract to temp directory
tar -xzf "$DIST_FILE" -C "$TEMP_DIR"

# Find the extracted directory
EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "Error: Could not find extracted directory"
    exit 1
fi

echo "Directory structure:"
echo ""
(cd "$EXTRACTED_DIR" && find . -type d | sort | sed 's|^\./||' | grep -v '^\.$' | sed 's/^/  /')

echo ""
echo "=== Key Directories Check ==="
echo ""

# Check for important directories and files
check_path() {
    local path="$1"
    local desc="$2"
    if [ -e "$EXTRACTED_DIR/$path" ]; then
        if [ -d "$EXTRACTED_DIR/$path" ]; then
            local count=$(find "$EXTRACTED_DIR/$path" -type f | wc -l | tr -d ' ')
            echo "✓ $desc ($count files)"
        else
            echo "✓ $desc"
        fi
    else
        echo "✗ $desc - NOT FOUND"
    fi
}

check_path "C++" "C++ source directory"
check_path "swig" "SWIG directory"
check_path "spec" "FIX specification directory"
check_path "LICENSE" "License file"
check_path "README.md" "README file"
check_path "setup.py" "Setup script"
check_path "PKG-INFO" "Package metadata"

echo ""
echo "=== File Counts by Type ==="
echo ""

(cd "$EXTRACTED_DIR" && find . -type f -name '*.h' | wc -l | xargs echo "  Header files (.h):")
(cd "$EXTRACTED_DIR" && find . -type f -name '*.hpp' | wc -l | xargs echo "  Header files (.hpp):")
(cd "$EXTRACTED_DIR" && find . -type f -name '*.cpp' | wc -l | xargs echo "  Source files (.cpp):")
(cd "$EXTRACTED_DIR" && find . -type f -name '*.py' | wc -l | xargs echo "  Python files (.py):")
(cd "$EXTRACTED_DIR" && find . -type f -name '*.xml' | wc -l | xargs echo "  XML spec files (.xml):")

echo ""

# Check specifically for swig files
SWIG_COUNT=$(cd "$EXTRACTED_DIR" && find swig -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$SWIG_COUNT" -gt 0 ]; then
    echo "=== SWIG Directory Contents ==="
    echo ""
    (cd "$EXTRACTED_DIR" && find swig -type f | sort | sed 's/^/  /')
    echo ""
else
    echo "⚠ WARNING: No files found in swig directory"
    echo ""
fi

# Check for C++ include paths referenced in setup.py
echo "=== Include Directories in setup.py ==="
echo ""
if [ -f "$EXTRACTED_DIR/setup.py" ]; then
    grep -E "include_dirs\s*=" "$EXTRACTED_DIR/setup.py" | sed 's/^/  /'
else
    echo "  setup.py not found"
fi

echo ""
echo "=== Inspection Complete ==="
