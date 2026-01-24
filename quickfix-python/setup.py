from setuptools import setup, Extension
import distutils.sysconfig
import glob

# Remove the "-Wstrict-prototypes" compiler option, which isn't valid for C++.
cfg_vars = distutils.sysconfig.get_config_vars()
for key, value in cfg_vars.items():
    if type(value) == str:
        cfg_vars[key] = value.replace("-Wstrict-prototypes", "")

setup(
    data_files=[('share/quickfix', glob.glob('spec/FIX*.xml'))],
    include_dirs=['C++', 'swig'],
    ext_modules=[
        Extension(
            '_quickfix',
            glob.glob('C++/*.cpp'),
            extra_compile_args=[
                '-std=c++17',
                '-Wno-deprecated',
                '-Wno-unused-variable',
                '-Wno-unused-label',
                '-Wno-deprecated-declarations',
                '-Wno-maybe-uninitialized',
                '-D__cpp_noexcept_function_type'
            ]
        )
    ],
)
