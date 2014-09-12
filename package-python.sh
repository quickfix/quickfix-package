rm -rf quickfix-python/C++
rm -rf quickfix-python/quickfix*.py
rm -rf quickfix-python/doc
rm -rf quickfix-python/LICENSE

mkdir quickfix-python/C++

cp quickfix/LICENSE quickfix-python

cp quickfix/src/python/*.py quickfix-python
cp quickfix/src/C++/*.h quickfix-python/C++
cp quickfix/src/C++/*.hpp quickfix-python/C++
cp quickfix/src/C++/*.cpp quickfix-python/C++
cp quickfix/src/python/QuickfixPython.cpp quickfix-python/C++
cp quickfix/src/python/QuickfixPython.h quickfix-python/C++

touch quickfix-python/C++/config.h
touch quickfix-python/C++/config_windows.h
rm -f quickfix-python/C++/stdafx.*

pushd quickfix-python

python setup.py sdist upload -r pypi
