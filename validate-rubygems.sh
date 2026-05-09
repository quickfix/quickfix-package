#!/bin/bash

# Script to validate QuickFix Ruby gem installed from RubyGems
# Usage: ./validate-rubygems.sh

echo "=== Validating QuickFix Ruby Gem from RubyGems ==="
echo ""

# Check if gem command is available
if ! command -v gem &> /dev/null; then
    echo "Error: gem command not found"
    echo "Install Ruby to get the gem command"
    exit 1
fi

echo "Validating gem from production: RubyGems.org"
echo ""

# Get installed version
INSTALLED=$(gem list quickfix_ruby | grep quickfix_ruby)

if [ -z "$INSTALLED" ]; then
    echo "quickfix_ruby gem not found locally"
    echo ""
    echo "Installing quickfix_ruby from RubyGems.org..."
    echo ""

    gem install quickfix_ruby -V 2>&1 | tail -20

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

TEST_SCRIPT=$(mktemp)
cat > "$TEST_SCRIPT" << 'EOF'
begin
  require 'quickfix'

  classes_to_test = [
    'Quickfix::Session',
    'Quickfix::SocketInitiatorBase',
    'Quickfix::SocketAcceptorBase',
    'Quickfix::Message',
    'Quickfix::FieldBase',
    'Quickfix::Group',
    'Quickfix::MessageStoreFactory',
    'Quickfix::DataDictionary',
  ]

  missing = []
  classes_to_test.each do |class_name|
    begin
      class_name.split('::').reduce(Object) { |m, c| m.const_get(c) }
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

  msg = Quickfix::Message.new
  field = Quickfix::StringField.new(35, 'D')
  msg.setField(field)

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
echo "  Repository: RubyGems.org"
echo ""
echo "The gem is working correctly!"
