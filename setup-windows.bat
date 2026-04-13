@echo off
echo Installing QuickFIX/n build dependencies...

winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
winget install --id DimitriVanHeesch.Doxygen -e --accept-package-agreements --accept-source-agreements
winget install --id Graphviz.Graphviz -e --accept-package-agreements --accept-source-agreements
winget install --id RubyInstallerTeam.RubyWithDevKit -e --accept-package-agreements --accept-source-agreements
winget install --id Python.Python.3 -e --accept-package-agreements --accept-source-agreements
winget install --id 7zip.7zip -e --accept-package-agreements --accept-source-agreements

echo Installing Visual Studio Build Tools with C++ workload...
winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

echo.
echo Open a new terminal to pick up updated PATH, then run:
echo   pip install twine
