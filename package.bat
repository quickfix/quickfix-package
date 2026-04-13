if "%1" == "" goto USAGE

set QF_VERSION=%1

rmdir /s/q quickfix

git clone --depth 1 https://github.com/quickfix/quickfix.git
rmdir /s/q quickfix\.git

pushd quickfix\doc
call document.bat
popd

del /Q quickfix.zip
7z a -tzip -xr!?git\* quickfix-%QF_VERSION%.zip quickfix

pushd quickfix
cmake .
cmake --build . --config release
popd

pushd quickfix\test
call runut.bat release 11111
call runat.bat release 11111
popd

7z a -tzip -xr!?git\* quickfix-bin-%QF_VERSION%.zip quickfix/include quickfix/lib/quickfix.lib quickfix/spec/FIX*.xml quickfix/doc/html

goto END

:USAGE
echo package.bat [qf version]

:END