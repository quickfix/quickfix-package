if "%1" == "" goto USAGE
if "%2" == "" goto USAGE

set VS_VERSION=%1
set QF_VERSION=%2

rmdir /s/q quickfix

git clone --depth 1 https://github.com/quickfix/quickfix.git
rmdir /s/q quickfix\.git

pushd quickfix\doc
call document.bat
popd

del /Q quickfix.zip
7z a -tzip -xr!?git\* quickfix-%QF_VERSION%.zip quickfix

pushd quickfix
call build_vs%VS_VERSION%.bat
popd

pushd quickfix\test
call runut.bat release 11111
call runat.bat release 11111
popd

7z a -tzip -xr!?git\* quickfix-bin-vs%VS_VERSION%-%QF_VERSION%.zip quickfix/include quickfix/lib/quickfix.lib quickfix/spec/FIX*.xml quickfix/doc/html 

goto END

:USAGE
echo build.bat [vs version] [qf version]

:END