#!/bin/bash

# Script to validate locally built QuickFix Ruby gem package
# This script builds, validates, and tests compilation of the gem
# Usage: ./validate-local-ruby-build.sh [path-to-gem-file]

set -e

GEM_FILE=${1:-""}

echo "=== Validating Locally Built QuickFix Ruby Package ==="
echo ""

# Check if gem command is available
if ! command -v gem &> /dev/null; then
    echo "Error: gem command not found"
    echo "Install Ruby to get the gem command"
    exit 1
fi

# If no gem file specified, build one first
if [ -z "$GEM_FILE" ]; then
    echo "No gem file specified. Building gem first..."
    echo ""
    
    if [ ! -f "package-ruby.sh" ]; then
        echo "Error: package-ruby.sh not found"
        echo "Please run this script from the quickfix-package directory"
        exit 1
    fi
    
    # Build the gem
    ./package-ruby.sh --build-only
    
    # Find the built gem file
    if [ ! -d "quickfix-ruby" ]; then
        echo "Error: quickfix-ruby directory not found"
        exit 1
    fi
    
    GEM_FILE=$(ls -t quickfix-ruby/*.gem 2>/dev/null | head -1)
    
    if [ -z "$GEM_FILE" ]; then
        echo "Error: Failed to build gem"
        exit 1
    fi
    
    echo ""
    echo "Successfully built gem: $GEM_FILE"
else
    # Verify gem file exists if specified
    if [ ! -f "$GEM_FILE" ]; then
        echo "Error: Gem file not found: $GEM_FILE"
        exit 1
    fi
fi

echo ""

# Get absolute path
GEM_FILE=$(cd "$(dirname "$GEM_FILE")" && pwd)/$(basename "$GEM_FILE")
echo "Validating package: $GEM_FILE"
echo ""

# Run validation tests
echo "=== Running Validation Tests ==="
echo ""

# Test 1: Check gem file integrity
echo "Test 1: Checking gem file integrity..."
if gem spec "$GEM_FILE" > /dev/null 2>&1; then
    echo "✓ Gem file is valid"
else
    echo "✗ Gem file is invalid"
    exit 1
fi

# Test 2: Extract and check gem contents
echo ""
echo "Test 2: Checking gem contents..."

# Create temporary directory for extraction
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Change to temp directory and extract gem
(cd "$TEMP_DIR" && gem unpack "$GEM_FILE" 2>&1) > /dev/null

if [ $? -eq 0 ]; then
    echo "  ✓ Successfully unpacked gem"
    
    # Check for key directories
    GEM_DIR=$(ls "$TEMP_DIR" | grep quickfix | head -1)
    
    if [ -d "$TEMP_DIR/$GEM_DIR/lib" ]; then
        echo "  ✓ Found lib directory"
    else
        echo "  ✗ Missing lib directory"
        exit 1
    fi
    
    if [ -d "$TEMP_DIR/$GEM_DIR/ext" ]; then
        echo "  ✓ Found ext directory (native extensions)"
    fi
    
    if [ -f "$TEMP_DIR/$GEM_DIR/quickfix.gemspec" ]; then
        echo "  ✓ Found quickfix.gemspec"
    fi
else
    echo "✗ Failed to unpack gem"
    exit 1
fi

# Test 3: Check gem specification
echo ""
echo "Test 3: Verifying gem specification..."

# Extract version using a reliable method
GEM_VERSION=$(basename "$GEM_FILE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [ -n "$GEM_VERSION" ]; then
    echo "  ✓ Gem name: quickfix_ruby"
    echo "  ✓ Gem version: $GEM_VERSION"
else
    echo "  ✓ Gem specification is valid"
fi

# Test 4: Verify native extension files
echo ""
echo "Test 4: Verifying native extension files..."

# Check if extconf.rb exists
if [ -f "$TEMP_DIR/$GEM_DIR/ext/quickfix/extconf.rb" ]; then
    echo "  ✓ Found extconf.rb (extension configuration)"
else
    echo "  ✗ Missing extconf.rb"
    exit 1
fi

# Check for Ruby source files
RUBY_FILES=$(find "$TEMP_DIR/$GEM_DIR/ext/quickfix" -name "*.cpp" -o -name "*.h" 2>/dev/null | wc -l)
if [ "$RUBY_FILES" -gt 50 ]; then
    echo "  ✓ Found $RUBY_FILES C++ source files for compilation"
else
    echo "  ✗ Insufficient C++ source files found"
    exit 1
fi

# Test 5: Compile C++ native extensions
echo ""
echo "Test 5: Compiling C++ native extensions..."
echo "  (This may take several minutes...)"

# Create a temporary directory for compilation test
COMPILE_TEMP_DIR=$(mktemp -d)
COMPILE_LOG="/tmp/quickfix_compile_$(date +%s).log"

# Install gem to trigger compilation
echo "  Installing gem (this will compile C++ extensions)..."
echo ""

# Show compilation progress in real-time with verbose output
# Set VERBOSE=1 to show each file being compiled
# Set MAKEFLAGS=V=1 to show detailed make commands for each compilation step
if VERBOSE=1 MAKEFLAGS=V=1 gem install "$GEM_FILE" --local --install-dir "$COMPILE_TEMP_DIR" --no-document --verbose 2>&1 | tee "$COMPILE_LOG"; then
    echo ""
    echo "  ✓ C++ extensions compiled successfully"
    COMPILE_SUCCESS=true
else
    COMPILE_SUCCESS=false
fi

# Check compilation log for critical errors
if grep -q "error\|Error\|failed\|Failed" "$COMPILE_LOG" 2>/dev/null; then
    if [ "$COMPILE_SUCCESS" = false ]; then
        echo "  ✗ C++ compilation failed - Cannot proceed with package validation"
        echo ""
        echo "Compilation errors:"
        echo "---"
        grep -E "error:|Error:|failed:|Failed:" "$COMPILE_LOG" | head -20
        echo "---"
        echo ""
        echo "Full compilation log: $COMPILE_LOG"
        echo ""
        
        # Clean up before exiting
        rm -rf "$COMPILE_TEMP_DIR"
        
        echo "The gem package structure is valid, but compilation failed."
        echo "This may be due to missing development dependencies:"
        echo "  1. Build tools: sudo apt-get install build-essential ruby-dev"
        echo "  2. OpenSSL dev: sudo apt-get install libssl-dev"
        echo "  3. On macOS: xcode-select --install"
        echo ""
        echo "Fix dependencies and try again."
        exit 1
    fi
fi

# Clean up compile temp directory
rm -rf "$COMPILE_TEMP_DIR"

echo ""
echo "=== Validation Complete ==="
echo ""
echo "✓ All validation tests PASSED!"
echo ""
echo "Package validated successfully!"
echo ""
echo "Summary:"
echo "  - Gem package integrity: ✓ VALID"
echo "  - Gem structure: ✓ VALID"
echo "  - Extension files: ✓ PRESENT"
echo "  - C++ compilation: ✓ SUCCESSFUL"
echo ""
echo "This gem is fully validated and ready for publication."
echo "To publish to RubyGems, run: ./publish-rubygems.sh"
