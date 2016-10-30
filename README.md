# Requirements #

[QuickFIX] uses [Automake] to compile. Standard requirements for different platforms:

#### Linux ####

TODO

#### macOS ####

Use [HomeBrew] to install the necessary utilities:
* Install [HomeBrew]: `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
* Install brew packages: `brew install automake libtool`

#### Windows ####

TODO

# Compilation #

* Build [QuickFIX]: `bash package.sh [quick_fix_version]`
* Build Python wrappers: `bash package-python.sh [-d]`
* Build Ruby wrappers: `bash package-ruby.sh`

[Autotools]: http://www.gnu.org/software/automake/manual/html_node/index.html
[HomeBrew]: http://brew.sh/
[QuickFIX]: http://www.quickfixengine.org/
[QuickFIX package index]: https://pypi.python.org/pypi/quickfix

