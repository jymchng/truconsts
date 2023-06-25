#!/usr/bin/env python

# https://github.com/ionelmc/python-nameless/blob/main/setup.py
import os
from pathlib import Path

from setuptools import Extension
from setuptools import find_packages
from setuptools import setup


# ROOT_DIR = os.path.dirname(__file__)
# PACKAGE_NAME = "truconsts"
# sys.path.append(os.path.join(ROOT_DIR, PACKAGE_NAME))
# CYTHON_DIR_NAME = "cy_src"
# C_FILES_DIRECTORY = os.path.join(ROOT_DIR, CYTHON_DIR_NAME)


# def generate_extensions(package_name, directory):
#     extensions = []
#     for root, dirs, files in os.walk(directory):
#         print(root, dirs, files)
#         for file in files:
#             if file.endswith('.c'):
#                 print(f"File ends with `.c`: {file}")
#                 file_name = os.path.splitext(file)[0]
#                 module_name = f"{package_name}.{file_name}"
#                 print(f"`sources` = {CYTHON_DIR_NAME}/{file}")
#                 extension = Extension(
#                     module_name, sources=[f"{CYTHON_DIR_NAME}/{file}"])
#                 extensions.append(extension)
#     return extensions


# ext_modules = generate_extensions(PACKAGE_NAME, C_FILES_DIRECTORY)
# print("Extension modules are: ", ext_modules)

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


# if __name__ == '__main__':
#     print(f"ROOT_DIR={ROOT_DIR}")
#     print(f"PACKAGE_NAME={PACKAGE_NAME}")
#     print(f"CYTHON_DIR_NAME={CYTHON_DIR_NAME}")
#     print(f"C_FILES_DIRECTORY={C_FILES_DIRECTORY}")
