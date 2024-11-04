#!/usr/bin/env bash

WITH_MYSQL=${WITH_MYSQL:-0}
WITH_POSTGRESQL=${WITH_POSTGRESQL:-0}
DEST_DIR=${DEST_DIR:-quickfix-py}

rm -rf "${DEST_DIR}/C++"
rm -rf "${DEST_DIR}/spec"
rm -rf "${DEST_DIR}/doc"
rm -rf "${DEST_DIR}/build"
rm -f "${DEST_DIR}/LICENSE"
rm -f "${DEST_DIR}/quickfix*.py"

cp quickfix/LICENSE "${DEST_DIR}"

cp quickfix/src/python3/*.py "${DEST_DIR}"
mkdir "${DEST_DIR}/C++"
cp quickfix/src/C++/*.h "${DEST_DIR}/C++"
cp quickfix/src/C++/*.hpp "${DEST_DIR}/C++"
cp quickfix/src/C++/*.cpp "${DEST_DIR}/C++"
cp -R quickfix/src/C++/double-conversion "${DEST_DIR}/C++"
cp quickfix/src/python3/QuickfixPython.cpp "${DEST_DIR}/C++"
cp quickfix/src/python3/QuickfixPython.h "${DEST_DIR}/C++"

mkdir "${DEST_DIR}/spec"
cp quickfix/spec/FIX*.xml "${DEST_DIR}/spec"

touch "${DEST_DIR}/C++/config.h"
touch "${DEST_DIR}/C++/config_windows.h"
rm -f "${DEST_DIR}/C++/stdafx.*"

cp -R quickfix/src/swig "${DEST_DIR}/C++"

#
# echo "Creating virtual environment..."
# rm -rf .venv
# python -m venv .venv
# # shellcheck disable=SC1091
# source .venv/bin/activate
# # python -m pip install build twine

# # pushd "${DEST_DIR}" || exit

# # python3 -m build --sdist # source distribution
# # python3 -m build --wheel # wheel distribution for current platform
# # # PYTHONWARNINGS="ignore" twine upload --repository-url https://test.pypi.org/legacy/ dist/*

# # popd || exit
