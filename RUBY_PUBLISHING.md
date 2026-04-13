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
   - Test: https://test.rubygems.org

3. **Configure authentication:**
   - Generate an API key: https://rubygems.org/profile/api_keys
   - Save credentials by running `gem push` once — it will prompt for your key and save it to `~/.gem/credentials`

## Publishing Workflow

### For Testing (Recommended First)

```bash
# Step 1: Build the gem
./package-ruby.sh --build-only

# Step 2: Validate locally (MUST pass before publishing)
./validate-local-ruby-build.sh

# Step 3: Publish to test repository
./publish-rubygems.sh --test

# Step 4: Validate the published gem
./validate-rubygems.sh --test
```

### For Production

```bash
# Step 1: Ensure local validation passes
./validate-local-ruby-build.sh

# Step 2: Publish to production RubyGems
./publish-rubygems.sh

# Step 3: Validate production publication
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

Publishes the gem to RubyGems.org or the test repository.

```bash
./publish-rubygems.sh [path-to-gem-file] [--test]
```

- Default: publishes to RubyGems.org (production)
- `--test`: publishes to test.rubygems.org

Requires credentials in `~/.gem/credentials`.

---

### validate-rubygems.sh

Validates the gem after it has been published and installed from a repository.

```bash
./validate-rubygems.sh [--test]
```

- Default: validates from RubyGems.org
- `--test`: validates from test.rubygems.org

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
# Run gem push manually — it will prompt for your API key and save credentials
gem push path/to/gem.gem

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
- [ ] `./publish-rubygems.sh --test` succeeds
- [ ] `./validate-rubygems.sh --test` passes
- [ ] No errors in `/tmp/quickfix_compile_*.log`
- [ ] Version number is correct and unique
- [ ] `./publish-rubygems.sh` succeeds for production

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./package-ruby.sh --build-only` | Build gem only |
| `./validate-local-ruby-build.sh` | Validate locally built gem (includes C++ compilation) |
| `./validate-local-ruby-build.sh FILE` | Validate a specific gem file |
| `./publish-rubygems.sh` | Publish to production RubyGems |
| `./publish-rubygems.sh --test` | Publish to test.rubygems.org |
| `./validate-rubygems.sh` | Validate gem from production |
| `./validate-rubygems.sh --test` | Validate gem from test repository |

## Resources

- RubyGems: https://rubygems.org
- Test RubyGems: https://test.rubygems.org
- RubyGems Publishing Guide: https://guides.rubygems.org/publishing/
- SWIG Ruby Documentation: http://www.swig.org/Doc4.2/Ruby.html
