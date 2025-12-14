# QuickFix Python Package Publishing Guide

This guide explains how to publish and validate the QuickFix Python package to PyPI (Python Package Index).

## Prerequisites

1. **Install required tools:**
   ```bash
   pip install twine build
   ```

2. **Set up PyPI accounts:**
   - Test PyPI: https://test.pypi.org/account/register/
   - Production PyPI: https://pypi.org/account/register/

3. **Configure authentication (recommended):**

   Create a `~/.pypirc` file with API tokens:
   ```ini
   [distutils]
   index-servers =
       pypi
       testpypi

   [pypi]
   username = __token__
   password = pypi-YOUR-PRODUCTION-TOKEN

   [testpypi]
   username = __token__
   password = pypi-YOUR-TEST-TOKEN
   ```

   To generate tokens:
   - Test PyPI: https://test.pypi.org/manage/account/#api-tokens
   - Production PyPI: https://pypi.org/manage/account/#api-tokens

## Publishing Workflow

### Option 1: Quick Publish to Test PyPI (Recommended for Testing)

Use the standalone publish script:

```bash
./publish-test-pypi.sh
```

This script:
- Cleans previous builds
- Builds the package from the prepared `quickfix-python/` directory
- Runs quality checks with `twine check`
- Uploads to Test PyPI

**Note:** You must run `./package-python.sh --build-only` first to prepare the package files.

### Option 2: Integrated Package and Publish

Use the enhanced `package-python.sh` script that handles both packaging and publishing:

```bash
# Build and upload to Test PyPI (default)
./package-python.sh

# Or explicitly specify Test PyPI
./package-python.sh --test-pypi

# Build and upload to Production PyPI
./package-python.sh --pypi

# Only build, don't upload
./package-python.sh --build-only
```

This script:
- Copies files from the main `quickfix/` repository
- Prepares the `quickfix-python/` directory
- Builds the distribution
- Optionally uploads based on the mode

## Validating Packages

### Inspect Package Contents

Before validating, you can inspect what's actually included in your distribution package:

```bash
./inspect-package.sh
```

Or inspect a specific distribution file:

```bash
./inspect-package.sh quickfix-python/dist/quickfix-0.0.1.tar.gz
```

This script shows:
- Directory structure of the package
- Presence of key directories (C++, swig, spec, etc.)
- File counts by type (.h, .cpp, .py, .xml)
- Contents of the swig directory
- Include directories referenced in setup.py

This is useful for quickly verifying that all necessary files (especially swig headers) are included before running full validation tests.

### Validate Local Build (Before Uploading)

**Recommended:** Test your locally built package before uploading to any PyPI repository:

```bash
./validate-local-build.sh
```

Or specify a specific distribution file:

```bash
./validate-local-build.sh quickfix-python/dist/quickfix-1.15.1.tar.gz
```

The local validation script:
1. Finds the most recent built package (or uses the specified file)
2. Runs `twine check` for package quality validation
3. Creates a fresh Python virtual environment
4. Installs the package from the local file
5. Runs comprehensive tests:
   - Module import test (all FIX version modules)
   - Core classes availability check
   - FIX specification files check
   - Message creation test (FIX 4.2, 4.4, 5.0)
   - SessionSettings configuration test
6. Reports success or failure

### Validate Published Package (After Uploading to Test PyPI)

After publishing to Test PyPI, validate that the package works correctly when installed by users:

```bash
./validate-test-pypi.sh
```

Or validate a specific version:

```bash
./validate-test-pypi.sh 1.15.1
```

The Test PyPI validation script:
1. Creates a fresh Python virtual environment
2. Installs the package from Test PyPI (simulating a real user installation)
3. Runs the following tests:
   - Module import test
   - Version check
   - Core classes availability check
   - FIX specification files check
   - Basic message creation test
4. Reports success or failure

### Validation Output

Successful validation will show:
```
✓ Successfully imported quickfix
✓ Installed version: 1.15.1
✓ All core classes are available
✓ FIX specification files are installed
✓ Basic FIX message creation successful
✓ All validation tests passed!
```

## Complete Publishing Workflow

### For Test PyPI (Recommended First):

```bash
# Step 1: Prepare and package
./package-python.sh --build-only

# Step 2: Inspect package contents (optional but recommended)
./inspect-package.sh

# Step 3: Validate the local build
./validate-local-build.sh

# Step 4: Publish to Test PyPI (only if local validation passed)
./publish-test-pypi.sh

# Step 5: Validate the published package
./validate-test-pypi.sh
```

### For Production PyPI:

```bash
# Step 1: Test everything on Test PyPI first (see above)

# Step 2: Build for production
./package-python.sh --build-only

# Step 3: Inspect package contents (verify swig and other files)
./inspect-package.sh

# Step 4: Validate the local build one more time
./validate-local-build.sh

# Step 5: Publish to Production PyPI (only if validation passed)
./package-python.sh --pypi

# Step 6: Validate from production
# Install in a new environment and test:
python3 -m venv prod_test
source prod_test/bin/activate
pip install quickfix
python -c "import quickfix; print('Success!')"
deactivate
```

## Troubleshooting

### Authentication Issues

If you get authentication errors:

1. **Using API tokens (recommended):**
   - Ensure your `~/.pypirc` file is correctly configured
   - Username should be `__token__`
   - Password should be your full API token (starts with `pypi-`)

2. **Using username/password:**
   - You'll be prompted during upload
   - For Test PyPI, use your test.pypi.org credentials
   - For Production, use your pypi.org credentials

### Build Failures

If the package fails to build:

1. Ensure you've cloned the quickfix repository first
2. Check that all required C++ source files exist
3. Verify Python development headers are installed
4. Check the build logs in `quickfix-python/build/`

### Missing Files in Package

If files (like swig headers) are missing from the distribution:

1. **Inspect the package first:** Run `./inspect-package.sh` to see what's included
2. **Check MANIFEST.in:** Ensure `quickfix-python/MANIFEST.in` includes all necessary directories
3. **Rebuild:** After fixing MANIFEST.in, rebuild with `./package-python.sh --build-only`
4. **Verify:** Run `./inspect-package.sh` again to confirm files are now included

### Validation Failures

If validation fails:

1. **Import errors:** The C++ extension may not have compiled correctly
2. **Missing classes:** Check the package version and source
3. **Missing spec files:** Verify `MANIFEST.in` includes the spec files
4. **Header file issues:** Use `./inspect-package.sh` to verify swig and C++ headers are included

### Version Already Exists

PyPI does not allow re-uploading the same version. If you need to fix something:

1. **Test PyPI:** You can delete the release and re-upload
2. **Production PyPI:** You must increment the version number in `setup.py`

## Best Practices

1. **Inspect package contents** - Run `./inspect-package.sh` to verify all files (especially swig headers) are included
2. **Always validate locally first** - Run `./validate-local-build.sh` before uploading anywhere
3. **Always test on Test PyPI first** before publishing to production
4. **Run validation after publishing** - Verify the package works when installed by users
5. **Increment version numbers** in `setup.py` before publishing
6. **Tag releases** in git to track published versions
7. **Keep credentials secure** - never commit `.pypirc` to git

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./package-python.sh --build-only` | Build package only |
| `./package-python.sh --test-pypi` | Build and upload to Test PyPI |
| `./package-python.sh --pypi` | Build and upload to Production PyPI |
| `./publish-test-pypi.sh` | Upload pre-built package to Test PyPI |
| `./inspect-package.sh` | Inspect contents of built package |
| `./inspect-package.sh FILE` | Inspect specific distribution file |
| `./validate-local-build.sh` | Validate locally built package before uploading |
| `./validate-local-build.sh FILE` | Validate specific local distribution file |
| `./validate-test-pypi.sh` | Validate package from Test PyPI |
| `./validate-test-pypi.sh VERSION` | Validate specific version from Test PyPI |

## Resources

- Test PyPI: https://test.pypi.org/
- Production PyPI: https://pypi.org/
- Twine documentation: https://twine.readthedocs.io/
- Python packaging guide: https://packaging.python.org/
