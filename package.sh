QF_VERSION=$1

rm -rf quickfix

git clone --depth 1 https://github.com/quickfix/quickfix.git
rm -rf quickfix/.git

pushd quickfix/doc
./document.sh
popd

pushd quickfix
../git2cl > ChangeLog
./bootstrap
popd

rm -f quickfix-$QF_VERSION.tar.gz

tar czvf quickfix-$QF_VERSION.tar.gz quickfix

pushd quickfix
./configure --with-python2 --with-python3 --with-ruby && make && make check
popd
