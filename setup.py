from setuptools import Extension, setup, find_packages
import os
import sys

ROOT_DIR = os.path.dirname(__file__)
PACKAGE_NAME = "truconsts"
sys.path.append(os.path.join(ROOT_DIR, PACKAGE_NAME))
CYTHON_DIR_NAME = "cy_src"
C_FILES_DIRECTORY = os.path.join(ROOT_DIR, CYTHON_DIR_NAME)


def generate_extensions(package_name, directory):
    extensions = []
    for root, dirs, files in os.walk(directory):
        print(root, dirs, files)
        for file in files:
            if file.endswith('.c'):
                print(f"File ends with `.c`: {file}")
                file_name = os.path.splitext(file)[0]
                module_name = f"{package_name}.{file_name}"
                print(f"`sources` = {CYTHON_DIR_NAME}/{file}")
                extension = Extension(
                    module_name, sources=[f"{CYTHON_DIR_NAME}/{file}"])
                extensions.append(extension)
    return extensions


ext_modules = generate_extensions(PACKAGE_NAME, C_FILES_DIRECTORY)
print("Extension modules are: ", ext_modules)

setup(
    package_dir={
        'truconsts': 'truconsts',
        'cy_src': 'cy_src'
    },
    ext_modules=ext_modules,
)


if __name__ == '__main__':
    print(f"ROOT_DIR={ROOT_DIR}")
    print(f"PACKAGE_NAME={PACKAGE_NAME}")
    print(f"CYTHON_DIR_NAME={CYTHON_DIR_NAME}")
    print(f"C_FILES_DIRECTORY={C_FILES_DIRECTORY}")
    print(generate_extensions(PACKAGE_NAME, C_FILES_DIRECTORY))
