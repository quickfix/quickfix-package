#!/bin/bash
docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/quickfix-python-wheels/manylinux.sh
docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_i686 linux32 /io/quickfix-python-wheels/manylinux.sh
