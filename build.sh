#!/usr/bin/env bash
WITH_MYSQL=${WITH_MYSQL:-0}

arguments=(--with-python --with-openssl)

pushd quickfix || exit
./bootstrap
./configure "${arguments[@]}" && make
# make check TODO: tests need to be fixed in the original quickfix
popd || exit

pushd quickfix/src/python || exit
echo "building Python interface..."
./swig.sh
popd || exit

./package-python.sh

pushd quickfix-py || exit
echo "building Python package..."
python -m build
popd || exit
