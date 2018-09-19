#!/bin/bash

rm -rf quickfix

git clone --depth 1 https://github.com/quickfix/quickfix.git
rm -rf quickfix/.git

#Install for the python at hand
rm -rf quickfix-python
cp -r /io/quickfix-python ./quickfix-python
rm -rf quickfix-python/C++
rm -rf quickfix-python/spec
rm -rf quickfix-python/quickfix*.py
rm -rf quickfix-python/doc
rm -rf quickfix-python/LICENSE

mkdir quickfix-python/C++
mkdir quickfix-python/spec

cp quickfix/LICENSE quickfix-python

cp quickfix/src/python3/*.py quickfix-python
cp quickfix/src/C++/*.h quickfix-python/C++
cp quickfix/src/C++/*.hpp quickfix-python/C++
cp quickfix/src/C++/*.cpp quickfix-python/C++
cp -R quickfix/src/C++/double-conversion quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.cpp quickfix-python/C++
cp quickfix/src/python3/QuickfixPython.h quickfix-python/C++

cp quickfix/spec/FIX*.xml quickfix-python/spec

touch quickfix-python/C++/config.h
touch quickfix-python/C++/config_windows.h
touch quickfix-python/C++/Allocator.h
rm -f quickfix-python/C++/stdafx.*

pushd quickfix-python
for PYBIN in /opt/python/*/bin/; do
	echo "$PYBIN"
	"${PYBIN}/pip" wheel . -w quickfix-python-wheels
done
for whl in quickfix-python-wheels/*.whl; do
    auditwheel repair "$whl" -w /io/quickfix-python-wheels/
done
popd

#pushd quickfix
#	./bootstrap
#	./configure --with-python2
#	make
#	pushd src/python2
#		make check
#	popd
#popd