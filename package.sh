QF_VERSION=$1

rm -rf quickfix

git clone https://github.com/quickfix/quickfix.git

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
./configure --with-python --with-ruby && make && make check
popd
