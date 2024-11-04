#!/usr/bin/env bash
WITH_MYSQL=${WITH_MYSQL:-0}

arguments=(--with-python --with-openssl)

# TODO: support building with mysql and postgresql support
# if [ "$WITH_MYSQL" -eq 1 ]; then
#     arguments+=(--with-mysql)
# fi

if [ -d quickfix ]; then
  echo "quickfix directory already exists."
  exit
fi

git clone https://github.com/pablodcar/quickfix
rm -rf quickfix/.git

# pushd quickfix/doc
# ./document.sh
# popd

pushd quickfix || exit
./bootstrap
./configure "${arguments[@]}" && make
# make check TODO: tests need to be fixed in the original quickfix
popd || exit

pushd quickfix/src/python || exit
echo "building Python interface..."
./swig.sh
popd || exit
