#!/bin/bash

# This test script makes a number of assumptions about its enviroment
# and therfore is not meant to be portable or even to be run from
# outside Autorevision's repository.

# Prep
set -e
make tarball

# Configure
testPath="$(cd "$(dirname "$0")"; pwd -P)"
vers="$(./autorevision -fo ./autorevision.cache -s VCS_TAG | sed -e 's:v/::')"
tdir="autorevision-${vers}"
tarball="${tdir}.tgz"
tmpdir="$(mktemp -dqt autorevision)"


# Copy the tarball to a temp directory
cp -a "${tarball}" "${tmpdir}"

cd "${tmpdir}"

# Decompress
tar -xf "${tarball}"

cd "${tdir}"

# Poke it to see it does anything
make clean

# Compare the results
cmp -s "autorevision.cache" "${testPath}/autorevision.cache"
