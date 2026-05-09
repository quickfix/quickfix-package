# QuickFIX Ruby Gem Publishing Guide

This guide explains how to publish and validate the QuickFIX Ruby gem to RubyGems.

## Prerequisites

1. **Install required tools:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install build-essential ruby-dev libssl-dev

   # macOS
   xcode-select --install
   ```

2. **Set up a RubyGems account:**
   - Production: https://rubygems.org

3. **Configure authentication:**
   - Generate an API key: https://rubygems.org/profile/api_keys
   - Save credentials:
     ```bash
     mkdir -p ~/.gem
     echo ':rubygems_api_key: YOUR_API_KEY' >> ~/.gem/credentials
     chmod 0600 ~/.gem/credentials
     ```

## Publishing Workflow

```bash
# Step 1: Build the gem
./package-ruby.sh --build-only

# Step 2: Validate locally (MUST pass before publishing)
./validate-local-ruby-build.sh

# Step 3: Publish to RubyGems
./publish-rubygems.sh

# Step 4: Validate the published gem
./validate-rubygems.sh
```

## Script Reference

### package-ruby.sh

Prepares and builds the gem.

```bash
./package-ruby.sh [--build-only | --rubygems]
```

- Copies C++ source files, headers, SWIG files, and config files from `quickfix/`
- Builds the gem using `gem build quickfix.gemspec`
- Output: `quickfix-ruby/*.gem`

---

### validate-local-ruby-build.sh

Validates the locally built gem, including a full C++ compilation test. This is the most important step — it proves the package will work when installed by users.

```bash
./validate-local-ruby-build.sh [path-to-gem-file]
```

Runs 5 tests:

1. **Gem file integrity** — verifies the gem can be read by RubyGems
2. **Gem contents** — checks for required `lib/`, `ext/` directories and `quickfix.gemspec`
3. **Gem specification** — validates gemspec metadata
4. **Extension files** — verifies `extconf.rb` and 50+ C++ source files are present
5. **C++ compilation** — installs the gem to a temp directory and actually compiles the native extension

Compiler output is saved to `/tmp/quickfix_compile_*.log` for debugging.

---

### publish-rubygems.sh

Publishes the gem to RubyGems.org.

```bash
./publish-rubygems.sh [path-to-gem-file]
```

Requires credentials in `~/.gem/credentials`.

---

### validate-rubygems.sh

Validates the gem after it has been published and installed from RubyGems.org.

```bash
./validate-rubygems.sh
```

Runs 3 tests:

1. **Installation check** — installs gem if needed, displays version
2. **Core classes** — verifies `Quickfix::Session`, `SocketInitiator`, `SocketAcceptor`, `Message`, etc. are importable
3. **Native extension functional** — creates a QuickFIX message and sets a field to confirm compiled code works

## Troubleshooting

### C++ Compilation Fails

```bash
# Check the detailed error log
cat /tmp/quickfix_compile_*.log

# Install missing build dependencies
sudo apt-get install build-essential ruby-dev libssl-dev  # Ubuntu/Debian
xcode-select --install                                     # macOS

# Clear build artifacts and retry
rm -rf quickfix-ruby/ext/quickfix/*.o quickfix-ruby/ext/quickfix/*.so
./validate-local-ruby-build.sh
```

### Publication Fails: Credentials Not Found

```bash
mkdir -p ~/.gem
echo ':rubygems_api_key: YOUR_API_KEY' >> ~/.gem/credentials
chmod 0600 ~/.gem/credentials

# Then retry
./publish-rubygems.sh path/to/gem.gem
```

### Gem Installs But Classes Not Found

```bash
# May be an architecture mismatch — clean and rebuild
gem uninstall quickfix_ruby -a
./validate-local-ruby-build.sh
gem install quickfix_ruby --local
```

## Verification Checklist

Before publishing to production:

- [ ] `./validate-local-ruby-build.sh` passes all 5 tests including C++ compilation
- [ ] No errors in `/tmp/quickfix_compile_*.log`
- [ ] Version number is correct and unique
- [ ] `./publish-rubygems.sh` succeeds

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./package-ruby.sh --build-only` | Build gem only |
| `./validate-local-ruby-build.sh` | Validate locally built gem (includes C++ compilation) |
| `./validate-local-ruby-build.sh FILE` | Validate a specific gem file |
| `./publish-rubygems.sh` | Publish to RubyGems.org |
| `./publish-rubygems.sh FILE` | Publish a specific gem file |
| `./validate-rubygems.sh` | Validate gem from RubyGems.org |

## Resources

- RubyGems: https://rubygems.org
- RubyGems Publishing Guide: https://guides.rubygems.org/publishing/
- SWIG Ruby Documentation: http://www.swig.org/Doc4.2/Ruby.html
