#!/usr/bin/env python

# https://github.com/ionelmc/python-nameless/blob/main/setup.py
import os
from pathlib import Path

from setuptools import Extension
from setuptools import find_packages
from setuptools import setup


for path in Path("src").glob("**/*.c"):
    print(
        """str(path.relative_to("src").with_suffix("")).replace(os.sep, ".") = """, str(
            path.relative_to("src").with_suffix("")).replace(
            os.sep, "."))
    print("sources = ", [str(path)])


setup(
    ext_modules=[
        Extension(
            str(path.relative_to("src").with_suffix("")).replace(os.sep, "."),
            sources=[str(path)],
            include_dirs=[str(path.parent)],
        )
        for path in Path("src").glob("**/*.c")
    ],
    packages=find_packages("src"),
    package_dir={"": "src"},
    py_modules=[path.stem for path in Path("src").glob("*.py")],
    include_package_data=True,
)
