#!/usr/bin/env bash

yum update -y
yum install openssl-devel swig -y

echo "Config libs: ${pkg-config --libs openssl}"
