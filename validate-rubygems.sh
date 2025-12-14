#!/bin/bash

# Script to validate QuickFix Ruby gem installed from RubyGems or test repository
# Usage: ./validate-rubygems.sh [--test]
# Default: validates from RubyGems.org
# With --test: validates from test.rubygems.org

TEST_SERVER=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            TEST_SERVER=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "=== Validating QuickFix Ruby Gem from RubyGems ==="
echo ""

# Check if gem command is available
if ! command -v gem &> /dev/null; then
    echo "Error: gem command not found"
    echo "Install Ruby to get the gem command"
    exit 1
fi

# Determine target server
if [ "$TEST_SERVER" = true ]; then
    SERVER_NAME="test.rubygems.org"
    echo "Validating gem from test server: $SERVER_NAME"
else
    SERVER_NAME="RubyGems.org"
    echo "Validating gem from production: $SERVER_NAME"
fi

echo ""

# Get installed version
INSTALLED=$(gem list quickfix_ruby | grep quickfix_ruby)

if [ -z "$INSTALLED" ]; then
    echo "quickfix_ruby gem not found locally"
    echo ""
    echo "Installing quickfix_ruby from $SERVER_NAME..."
    echo ""
    
    if [ "$TEST_SERVER" = true ]; then
        gem install quickfix_ruby --source https://test.rubygems.org/api/v1/ -V 2>&1 | tail -20
    else
        gem install quickfix_ruby -V 2>&1 | tail -20
    fi
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "Error: Failed to install quickfix_ruby"
        exit 1
    fi
fi

echo ""
echo "=== Running Validation Tests ==="
echo ""

# Test 1: Check gem is installed
echo "Test 1: Checking gem installation..."
if gem list quickfix_ruby | grep -q quickfix_ruby; then
    GEM_VERSION=$(gem list quickfix_ruby | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\..*)?')
    echo "✓ Gem installed: quickfix_ruby $GEM_VERSION"
else
    echo "✗ Gem not installed"
    exit 1
fi

# Test 2: Check core classes available
echo ""
echo "Test 2: Checking core QuickFIX classes..."

# Create a test Ruby script to verify classes
TEST_SCRIPT=$(mktemp)
cat > "$TEST_SCRIPT" << 'EOF'
begin
  require 'quickfix'
  
  # Test basic classes
  classes_to_test = [
    'Quickfix::Session',
    'Quickfix::SocketInitiator',
    'Quickfix::SocketAcceptor',
    'Quickfix::Message',
    'Quickfix::Field',
    'Quickfix::Group',
    'Quickfix::MessageFactory',
    'Quickfix::DataDictionaryProvider',
  ]
  
  missing = []
  classes_to_test.each do |class_name|
    begin
      Object.const_get(class_name.split('::'))
      puts "  ✓ #{class_name}"
    rescue NameError
      missing << class_name
    end
  end
  
  if missing.empty?
    puts ""
    puts "All core classes available!"
    exit 0
  else
    puts ""
    puts "Missing classes: #{missing.join(', ')}"
    exit 1
  end
rescue LoadError => e
  puts "Error: Failed to load quickfix: #{e.message}"
  exit 1
end
EOF

if ruby "$TEST_SCRIPT"; then
    echo "✓ Core QuickFIX classes are available"
else
    echo "✗ Failed to verify core classes"
    rm -f "$TEST_SCRIPT"
    exit 1
fi

rm -f "$TEST_SCRIPT"

# Test 3: Check native extension
echo ""
echo "Test 3: Checking native extension..."

TEST_SCRIPT=$(mktemp)
cat > "$TEST_SCRIPT" << 'EOF'
begin
  require 'quickfix'
  
  # Try to create a simple message
  msg = Quickfix::Message.new
  
  # Try to set a field
  field = Quickfix::Field(35)
  msg.setField(field, 'D')
  
  puts "✓ Native extension working"
  exit 0
rescue => e
  puts "✗ Error testing native extension: #{e.message}"
  exit 1
end
EOF

if ruby "$TEST_SCRIPT"; then
    echo "✓ Native extension is functional"
else
    echo "✗ Native extension test failed"
    rm -f "$TEST_SCRIPT"
    exit 1
fi

rm -f "$TEST_SCRIPT"

echo ""
echo "=== Validation Complete ==="
echo ""
echo "✓ All validation tests PASSED!"
echo ""
echo "Package Summary:"
echo "  Package: quickfix_ruby"
echo "  Version: $GEM_VERSION"
echo "  Status: Installed and functional"
echo "  Repository: $SERVER_NAME"
echo ""
echo "The gem is working correctly!"
