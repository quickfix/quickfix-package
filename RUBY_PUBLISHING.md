# QuickFIX Ruby Packaging Workflow

This document describes the complete Ruby gem packaging workflow for QuickFIX Ruby bindings. The workflow mirrors the Python packaging process and ensures complete validation including C++ compilation.

## Overview

The Ruby packaging system includes 4 main scripts that work together:

1. **package-ruby.sh** - Prepares and builds the gem
2. **validate-local-ruby-build.sh** - Validates locally built gem (includes C++ compilation test)
3. **publish-rubygems.sh** - Publishes gem to RubyGems or test repository
4. **validate-rubygems.sh** - Validates gem after installation from repository

## Detailed Workflow

### 1. Building the Gem

```bash
./package-ruby.sh [--build-only | --rubygems]
```

**What it does:**
- Prepares the `quickfix-ruby` directory structure
- Copies all necessary source files from `quickfix` subdirectory
- Copies C++ headers and implementation files
- Copies SWIG headers needed for compilation
- Copies config files (config.h, config_unix.h) from the C++ build
- Builds the gem using `gem build quickfix.gemspec`

**Options:**
- `--build-only`: Only prepares the directory structure and builds the gem (default)
- `--rubygems`: Same as --build-only (for compatibility)

**Output:**
- `quickfix-ruby/*.gem` - The built gem file ready for publishing or local validation

### 2. Validating Locally Built Gem (Most Important)

```bash
./validate-local-ruby-build.sh [path-to-gem-file]
```

**What it does:**

This is the critical validation step that verifies the package would work if published. It runs 5 comprehensive tests:

**Test 1: Gem File Integrity**
- Verifies the gem file structure using `gem spec`
- Ensures the gem can be read by RubyGems

**Test 2: Gem Contents**
- Unpacks the gem to verify structure
- Checks for required directories: `lib/`, `ext/`
- Checks for required files: `quickfix.gemspec`

**Test 3: Gem Specification**
- Extracts and displays gem name and version
- Validates gemspec is readable

**Test 4: Extension Files**
- Verifies `ext/quickfix/extconf.rb` exists
- Counts C++ source files (must have 50+ files)
- Ensures build configuration is present

**Test 5: C++ Compilation (CRITICAL)**
- This is the key test that actually compiles the C++ extensions
- Installs the gem to a temporary directory
- Triggers the Ruby native extension compilation via `gem install`
- Captures compilation output and logs
- Fails if compilation errors are detected
- Succeeds only if all C++ code compiles cleanly

**Output:**
- Exit code 0: All tests passed, package is valid
- Exit code 1: Any test failed, package cannot be published
- Compiler log saved to `/tmp/quickfix_compile_*.log` for debugging

**Why this is important:**
This test actually compiles the C++ code using your local compiler environment. It proves that a user installing the gem will be able to successfully build the native extensions. This is the most critical validation step.

### 3. Publishing to Repository

```bash
# Publish to production RubyGems.org
./publish-rubygems.sh [path-to-gem-file]

# Publish to test.rubygems.org (for testing)
./publish-rubygems.sh [path-to-gem-file] --test
```

**What it does:**
- Verifies RubyGems credentials exist in `~/.gem/credentials`
- Uses `gem push` to upload the gem
- Supports both production and test repositories

**Prerequisites:**
- Valid RubyGems account
- API key configured: https://rubygems.org/profile/api_keys
- Credentials saved (typically done automatically on first push attempt)

**Output:**
- Displays gem details and repository link on success
- Exit code 0: Published successfully
- Exit code 1: Publication failed (check credentials)

### 4. Validating Published Gem

```bash
# Validate gem from production RubyGems.org
./validate-rubygems.sh

# Validate gem from test.rubygems.org
./validate-rubygems.sh --test
```

**What it does:**
- Installs the gem from the specified repository
- Runs 3 validation tests:

**Test 1: Installation Check**
- Verifies gem is installed and shows version
- Installs from repository if not already installed

**Test 2: Core Classes Available**
- Tests that all major QuickFIX classes can be imported:
  - `Quickfix::Session`
  - `Quickfix::SocketInitiator`
  - `Quickfix::SocketAcceptor`
  - `Quickfix::Message`
  - And others...

**Test 3: Native Extension Functional**
- Actually exercises the native extension
- Creates a QuickFIX Message
- Sets a field to verify compiled code works

**Output:**
- Exit code 0: Gem is fully functional
- Exit code 1: Validation failed

## Complete Workflow Example

### Development and Testing

```bash
# 1. Build the gem
./package-ruby.sh --build-only

# 2. Validate local build (MUST pass all tests including C++ compilation)
./validate-local-ruby-build.sh

# 3. Test on test repository
./publish-rubygems.sh --test

# 4. Validate from test repository
./validate-rubygems.sh --test
```

### Production Release

```bash
# 1. Ensure local validation passes
./validate-local-ruby-build.sh

# 2. Publish to production RubyGems
./publish-rubygems.sh

# 3. Validate production publication
./validate-rubygems.sh
```

## Build Requirements

To successfully build and validate the gem, you need:

### Required System Packages (Linux - Ubuntu/Debian)
```bash
sudo apt-get install build-essential ruby-dev libssl-dev
```

### Required System Packages (macOS)
```bash
xcode-select --install
```

### Required Software
- Ruby (1.8.7 or later, tested with 2.x+)
- RubyGems (comes with Ruby)
- g++ with C++17 support
- OpenSSL development headers

## Troubleshooting

### Validation Fails: C++ Compilation Error

If `validate-local-ruby-build.sh` fails with compilation errors:

1. Check the detailed error log:
   ```bash
   cat /tmp/quickfix_compile_*.log
   ```

2. Install missing dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install build-essential ruby-dev libssl-dev

   # macOS
   xcode-select --install
   ```

3. Clear build artifacts and try again:
   ```bash
   rm -rf quickfix-ruby/ext/quickfix/*.o
   rm -rf quickfix-ruby/ext/quickfix/*.so
   ./validate-local-ruby-build.sh
   ```

### Publication Fails: Credentials Not Found

If `publish-rubygems.sh` fails with credential errors:

1. Create an API key:
   - Visit: https://rubygems.org/profile/api_keys
   - Create a new API key

2. Run gem push manually to save credentials:
   ```bash
   gem push path/to/gem.gem
   ```
   This will prompt for your API key and save it.

3. Try publication again:
   ```bash
   ./publish-rubygems.sh path/to/gem.gem
   ```

### Gem Installs But Classes Not Available

If `validate-rubygems.sh` fails to find classes:

1. The gem may have been built on a different architecture
2. Rebuild and re-validate:
   ```bash
   ./validate-local-ruby-build.sh
   gem uninstall quickfix_ruby -a
   gem install quickfix_ruby --local
   ```

## How It Differs from Python Workflow

| Aspect | Python | Ruby |
|--------|--------|------|
| Build Command | `python -m build` | `gem build gemspec` |
| Local Validation | `twine check` | `gem install` (triggers compilation) |
| Repository Test | test.pypi.org | test.rubygems.org |
| Publish Command | `twine upload` | `gem push` |
| Installation Check | `pip install` | `gem install` |
| Validation Library | twine | bundled gem tooling |

## Verification Checklist

Before publishing to production, verify:

- [ ] `./validate-local-ruby-build.sh` passes all 5 tests, especially C++ compilation
- [ ] `./publish-rubygems.sh --test` publishes to test repository successfully
- [ ] `./validate-rubygems.sh --test` validates successfully from test repository
- [ ] No compilation errors in `/tmp/quickfix_compile_*.log`
- [ ] Version number is correct and unique
- [ ] CHANGELOG is updated
- [ ] `./publish-rubygems.sh` publishes to production successfully

## Key Differences from Manual Gem Publishing

The automated workflow provides:

1. **Consistent Validation** - Same tests every time
2. **C++ Compilation Verification** - Ensures package works before publishing
3. **Test Repository Support** - Validate on test.rubygems.org before production
4. **Clear Error Messages** - Detailed feedback on what failed and why
5. **Scripted Publication** - No manual steps prone to error

## References

- QuickFIX Engine: http://www.quickfixengine.org
- RubyGems: https://rubygems.org
- Test RubyGems: https://test.rubygems.org
- Gem Publishing Guide: https://guides.rubygems.org/publishing/
- SWIG Ruby Documentation: http://www.swig.org/Doc4.2/Ruby.html
