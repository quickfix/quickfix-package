# Ruby Packaging Scripts Index

This document provides an index and quick reference for all Ruby packaging-related files.

## Executable Scripts

Located in: `/home/parallels/Src/quickfix-package/`

### 1. package-ruby.sh
**Purpose:** Build the QuickFIX Ruby gem

**Usage:**
```bash
./package-ruby.sh [--build-only|--rubygems]
```

**What it does:**
- Prepares the `quickfix-ruby/` directory structure
- Copies C++ source files, headers, and SWIG files from `quickfix/src/`
- Copies critical config files: `config.h`, `config_unix.h`
- Builds the gem using `gem build quickfix.gemspec`
- Exit code 0 = success, 1 = failure

**Output:** `quickfix-ruby/*.gem` file ready for validation or publishing

**Related files modified:**
- `quickfix-ruby/ext/quickfix/extconf.rb` - Ruby native extension configuration
- `quickfix-ruby/ext/quickfix/QuickfixRuby.cpp` - SWIG-generated wrapper with QuickFIX includes
- `quickfix/src/swig/*.h` - SWIG headers copied during build

---

### 2. validate-local-ruby-build.sh ⭐ CRITICAL
**Purpose:** Validate locally built gem including C++ compilation test

**Usage:**
```bash
./validate-local-ruby-build.sh [path-to-gem-file]
```

**What it does:**
Runs 5 comprehensive validation tests:

1. **Gem File Integrity** - Verifies gem can be read by RubyGems
2. **Gem Contents** - Checks for required directories and files
3. **Gem Specification** - Validates gemspec metadata
4. **Extension Files** - Verifies C++ source files present
5. **C++ Compilation** - **ACTUALLY COMPILES** the C++ code via `gem install`

**Critical behavior:**
- Uses `gem install` to trigger actual native extension compilation
- Captures compiler output in `/tmp/quickfix_compile_*.log`
- Exit code 0 = ready to publish, 1 = compilation or validation failed
- This test **PROVES** the package will work if published

**Output:**
- Console: Clear PASS/FAIL for each test
- Log file: `/tmp/quickfix_compile_*.log` contains full compiler output

---

### 3. publish-rubygems.sh
**Purpose:** Publish gem to RubyGems.org or test.rubygems.org

**Usage:**
```bash
./publish-rubygems.sh [path-to-gem-file] [--test]
```

**What it does:**
- Verifies RubyGems credentials in `~/.gem/credentials`
- Uses `gem push` to upload gem to repository
- Supports both production and test repositories

**Options:**
- `--test` - Publish to test.rubygems.org (for testing)
- Default - Publish to RubyGems.org (production)

**Prerequisites:**
- RubyGems account: https://rubygems.org
- API key configured: https://rubygems.org/profile/api_keys
- Credentials saved to `~/.gem/credentials`

**Exit code:** 0 = published, 1 = failed

---

### 4. validate-rubygems.sh
**Purpose:** Validate gem after publication from repository

**Usage:**
```bash
./validate-rubygems.sh [--test]
```

**What it does:**
Runs 3 validation tests on installed gem:

1. **Installation Check** - Installs gem if needed, displays version
2. **Core Classes** - Verifies QuickFIX classes importable:
   - `Quickfix::Session`
   - `Quickfix::SocketInitiator`
   - `Quickfix::SocketAcceptor`
   - `Quickfix::Message`
   - And others...
3. **Native Extension** - Tests compiled code by creating messages and setting fields

**Options:**
- `--test` - Validate from test.rubygems.org
- Default - Validate from RubyGems.org (production)

**Exit code:** 0 = valid, 1 = failed

---

## Documentation Files

### RUBY_PUBLISHING.md
**Complete technical documentation covering:**
- Detailed explanation of each script and workflow
- Build requirements for different OS
- Troubleshooting guide with solutions
- Comparison with Python packaging workflow
- Verification checklist before publishing
- File size: ~8.3 KB

**Start here for:** Understanding the complete workflow in depth

---

### RUBY_WORKFLOW_QUICK_REFERENCE.txt
**Quick reference guide with:**
- 1-page script summary
- Development & testing workflow
- Production release workflow
- Key features explanation
- Requirements checklist
- Troubleshooting FAQ with common issues and solutions
- Example complete workflow with output

**Start here for:** Quick lookup and immediate guidance

---

### RUBY_SCRIPTS_INDEX.md (this file)
**Index and file reference containing:**
- Location and purpose of each script
- Usage syntax and options
- What each script does
- Exit codes and outputs
- Related configuration files
- Complete workflow reference

**Start here for:** Finding specific information about scripts

---

## Complete Workflow

### Test Workflow
```bash
# 1. Build gem
./package-ruby.sh --build-only

# 2. Validate locally (CRITICAL - tests C++ compilation)
./validate-local-ruby-build.sh

# 3. Publish to test repository
./publish-rubygems.sh --test

# 4. Validate from test repository
./validate-rubygems.sh --test
```

### Production Workflow
```bash
# 1. Ensure local validation passes (MUST DO THIS FIRST!)
./validate-local-ruby-build.sh

# 2. Publish to production
./publish-rubygems.sh

# 3. Validate from production
./validate-rubygems.sh
```

---

## Configuration Files

### extconf.rb
**Location:** `quickfix-ruby/ext/quickfix/extconf.rb`
**Purpose:** Ruby native extension compilation configuration
**Key settings:**
- C++ compiler: g++
- C++ version: C++17 (`-std=c++17`)
- Warning suppressions for compatibility
- Macro: `-D__cpp_noexcept_function_type`

---

### QuickfixRuby.cpp
**Location:** `quickfix-ruby/ext/quickfix/QuickfixRuby.cpp`
**Purpose:** SWIG-generated C++ wrapper for Ruby bindings
**Key updates:**
- Added 10+ QuickFIX header includes
- Includes: Utility.h, Acceptor.h, Application.h, SocketAcceptor.h, etc.
- These enable compilation of SWIG-wrapped QuickFIX classes

---

## System Requirements

### Build Dependencies (Ubuntu/Debian)
```bash
sudo apt-get install build-essential ruby-dev libssl-dev
```

### Build Dependencies (macOS)
```bash
xcode-select --install
```

### Required Software
- Ruby 1.8.7 or later (tested with 2.x+)
- RubyGems (included with Ruby)
- g++ with C++17 support
- OpenSSL development headers

---

## Exit Codes

| Script | Exit 0 | Exit 1 |
|--------|--------|--------|
| package-ruby.sh | Gem built successfully | Build failed |
| validate-local-ruby-build.sh | All tests passed, ready to publish | Any test failed or compilation failed |
| publish-rubygems.sh | Gem published successfully | Publication failed |
| validate-rubygems.sh | Gem valid and functional | Gem invalid or classes missing |

---

## Quick Troubleshooting

**C++ Compilation Fails:**
```bash
# Install build dependencies
sudo apt-get install build-essential ruby-dev libssl-dev

# Check compilation log
cat /tmp/quickfix_compile_*.log
```

**Publishing Fails (Credentials):**
```bash
# Save credentials
gem push path/to/gem.gem
# Follow prompts to enter API key (saved automatically)

# Try again
./publish-rubygems.sh path/to/gem.gem
```

**Classes Not Found After Install:**
```bash
# Clean and rebuild
gem uninstall quickfix_ruby -a
./validate-local-ruby-build.sh
gem install quickfix_ruby --local
```

---

## Key Differences from Python Workflow

| Aspect | Python | Ruby |
|--------|--------|------|
| Build Tool | `python -m build` | `gem build` |
| Local Validation | `twine check` | `gem install` (compiles C++) |
| Repository Test | test.pypi.org | test.rubygems.org |
| Publish Tool | `twine upload` | `gem push` |
| Credentials | `~/.pypirc` | `~/.gem/credentials` |
| C++ Compilation | Not tested in validation | Tested in validate-local-ruby-build.sh |

---

## Related Resources

- **QuickFIX Engine:** http://www.quickfixengine.org
- **RubyGems Official:** https://rubygems.org
- **RubyGems Test:** https://test.rubygems.org
- **RubyGems Publishing Guide:** https://guides.rubygems.org/publishing/
- **SWIG Ruby Documentation:** http://www.swig.org/Doc4.2/Ruby.html

---

## File Checklist

Before considering deployment complete:
- [ ] All 4 scripts executable (`-rwxr-xr-x`)
- [ ] RUBY_PUBLISHING.md exists
- [ ] RUBY_WORKFLOW_QUICK_REFERENCE.txt exists
- [ ] extconf.rb uses C++17 flags
- [ ] QuickfixRuby.cpp includes QuickFIX headers
- [ ] package-ruby.sh copies SWIG headers
- [ ] validate-local-ruby-build.sh compiles C++ code
- [ ] publish-rubygems.sh supports --test flag
- [ ] validate-rubygems.sh tests core classes

---

**Last Updated:** 2024-01-24

For detailed information, see [RUBY_PUBLISHING.md](RUBY_PUBLISHING.md)
For quick reference, see [RUBY_WORKFLOW_QUICK_REFERENCE.txt](RUBY_WORKFLOW_QUICK_REFERENCE.txt)
