
# Scripts to package quickfix in Python

Based on https://github.com/quickfix/quickfix-package, original author: Oren Miller (oren@quickfixengine.org)

This project is an update to run with latest changes,
and compile and distribute a package in Python 3 with SSL support.

# Why

The original package is not being maintained.

# Build Instructions

# On OSX

## Install Python using pyenv

Ensure you have g++, openssl, python-dev, autoconf, etc. (run ./setup-osx.sh if needed)
Ensure you are using the same Python version you would use in the application when building.

1. Setting Environment Variables flags to enable SSL:

On MacOS:

```
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include -DHAVE_SSL=1"
```

On Linux:

```
export LDFLAGS="-L/usr/lib/aarch64-linux-gnu"
export CPPFLAGS="-I/usr/include/openssl -DHAVE_SSL=1"
```

2. Build sources

```
./build.sh
```

This step will download quickfix source code from repository
https://github.com/pablodcar/quickfix and leave C++ and compiled objects into `quickfix` directory.

3. Use the C++ source code to update the Python package

```
./package-python.sh
```

# Publishing

1. Create and activate a virtual environment to install distribution dependencies:

```
python -m pip install --upgrade build twine
```

2. Create Distribution files

```
python -m build
```

This step will leave a `dist/` directory with .tar.gz file (source distribution) and a .whl file (a built distribution). Built distribution depends on the OS, architecture, Python version.

e.g.
```
ls -1 dist
quickfix-py-0.0.1.tar.gz
quickfix_py-0.0.1-cp311-cp311-macosx_14_0_arm64.whl
```

3. Publish to PyPi (manual)

If you are going to test how the package looks like, use TestPyPi https://test.pypi.org/account/register/:

    * Follow the instructions to create a token: https://packaging.python.org/en/latest/tutorials/packaging-projects/#uploading-the-distribution-archives,
    * Configure the token on your local environment, e.g. ~/.pypirc


```
python3 -m twine upload --repository testpypi dist/*
```

Remove the option --repository testpypi to use the production repository.

4. Publish to PyPi (Github actions)

Before executing the action pypa/gh-action-pypi-publish, you need to register the Github Repository as a _trusted publisher_. see [Adding a trusted publisher to an existing PyPI project](https://docs.pypi.org/trusted-publishers/adding-a-publisher/)
