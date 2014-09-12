from distutils.core import setup
from distutils.core import Extension
from distutils.command.install import install
from distutils.command.build import build

import subprocess
import shutil
import glob
import os

long_description=''
with open('LICENSE') as file:
    license = file.read();

setup(name='quickfix',
      version='1.14.1',
      py_modules=['quickfix', 'quickfixt11', 'quickfix40', 'quickfix41', 'quickfix42', 'quickfix43', 'quickfix44', 'quickfix50', 'quickfix50sp1', 'quickfix50sp2'],
      author='Oren Miller',
      author_email='oren@quickfixengine.org',
      maintainer='Oren Miller',
      maintainer_email='oren@quickfixengine.org',
      description="FIX (Financial Information eXchange) protocol implementation",
      url='http://www.quickfixengine.org',
      download_url='http://www.quickfixengine.org',
      license=license,
      include_dirs=['C++'],
      ext_modules=[Extension('_quickfix', glob.glob('C++/*.cpp'), extra_compile_args=['-std=c++0x'])],
)
