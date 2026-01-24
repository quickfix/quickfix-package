#!/bin/bash

# Script to publish QuickFix Ruby gem to RubyGems or test repository
# Usage: ./publish-rubygems.sh [path-to-gem-file] [--test]
# Default: publishes to RubyGems
# With --test: publishes to test.rubygems.org

GEM_FILE=""
TEST_SERVER=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --test)
            TEST_SERVER=true
            shift
            ;;
        *)
            GEM_FILE=$1
            shift
            ;;
    esac
done

echo "=== Publishing QuickFix Ruby Gem ==="
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
    SERVER_URL="https://test.rubygems.org/api/v1/gems"
    echo "Publishing to test server: $SERVER_NAME"
else
    SERVER_NAME="RubyGems.org"
    SERVER_URL="https://rubygems.org/api/v1/gems"
    echo "Publishing to production: $SERVER_NAME"
fi

echo ""

# If no gem file specified, find the latest one
if [ -z "$GEM_FILE" ]; then
    if [ ! -d "quickfix-ruby" ]; then
        echo "Error: quickfix-ruby directory not found"
        echo "Build the gem first with: ./package-ruby.sh"
        exit 1
    fi
    
    GEM_FILE=$(ls -t quickfix-ruby/*.gem 2>/dev/null | head -1)
    
    if [ -z "$GEM_FILE" ]; then
        echo "Error: No gem file found"
        echo "Build the gem first with: ./package-ruby.sh"
        exit 1
    fi
fi

# Verify gem file exists
if [ ! -f "$GEM_FILE" ]; then
    echo "Error: Gem file not found: $GEM_FILE"
    exit 1
fi

echo "Publishing: $GEM_FILE"
echo ""

# Check for RubyGems credentials
CREDENTIALS_FILE="${HOME}/.gem/credentials"

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Error: RubyGems credentials not found"
    echo ""
    echo "Please configure your RubyGems credentials:"
    echo "  1. Visit: https://rubygems.org/profile/api_keys"
    echo "  2. Create an API key"
    echo "  3. Run: gem push $GEM_FILE"
    echo ""
    echo "This will prompt you to enter your API key and save credentials."
    exit 1
fi

# Publish the gem
echo "Pushing gem to $SERVER_NAME..."
echo ""

if [ "$TEST_SERVER" = true ]; then
    # For test server, we typically use the default credentials or specific test credentials
    # Most setups use the standard gem push which reads from ~/.gem/credentials
    gem push "$GEM_FILE" --host https://test.rubygems.org
else
    gem push "$GEM_FILE"
fi

PUSH_EXIT_CODE=$?

echo ""

if [ $PUSH_EXIT_CODE -eq 0 ]; then
    echo "=== Publication Successful ==="
    echo ""
    echo "✓ Gem published successfully!"
    
    # Extract version from filename
    GEM_VERSION=$(basename "$GEM_FILE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    
    if [ -n "$GEM_VERSION" ]; then
        echo ""
        echo "Gem details:"
        echo "  Name: quickfix_ruby"
        echo "  Version: $GEM_VERSION"
        echo "  Repository: $SERVER_NAME"
        
        if [ "$TEST_SERVER" = true ]; then
            echo ""
            echo "To verify the gem, visit:"
            echo "  https://test.rubygems.org/gems/quickfix_ruby/versions/$GEM_VERSION"
        else
            echo ""
            echo "To verify the gem, visit:"
            echo "  https://rubygems.org/gems/quickfix_ruby"
        fi
    fi
    
    exit 0
else
    echo "=== Publication Failed ==="
    echo ""
    echo "✗ Failed to publish gem (exit code: $PUSH_EXIT_CODE)"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check your RubyGems credentials: $CREDENTIALS_FILE"
    echo "  2. Verify your API key is valid"
    echo "  3. For test server, ensure credentials support test.rubygems.org"
    echo "  4. Try validating first: ./validate-local-ruby-build.sh $GEM_FILE"
    
    exit 1
fi
