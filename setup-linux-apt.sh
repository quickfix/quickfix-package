#!/usr/bin/env bash

apt-get update -y
apt-get install libssl-dev swig -y

echo "Config libs: ${pkg-config --libs openssl}"
