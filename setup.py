from setuptools import Extension, setup
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
    # name='truconsts',
    # version="0.0.5",
    # description='Manage all your constants in your Python application',
    # author='Jim Chng',
    # author_email='jimchng@outlook.com',
    # url='http://github.com/jymchng/truconsts',
    packages=['truconsts', 'cy_src'],
    package_dir={
        'truconsts': 'truconsts',
        'cy_src': 'cy_src'
    },
    # package_data={"truconsts": ["py.typed", "secrets.pyi"]},
    # include_package_data=True,
    ext_modules=ext_modules,
    # long_description=open('README.md').read(),
    # long_description_content_type='text/markdown',
    # classifiers=[
    #     "Development Status :: 3 - Alpha",
    #     "License :: OSI Approved :: MIT License",
    #     "Programming Language :: Python",
    #     "Programming Language :: Python :: 3.8",
    #     "Programming Language :: Python :: 3.9",
    #     "Programming Language :: Python :: 3.10",
    #     "Programming Language :: Python :: 3.11",
    #     "Programming Language :: Python :: Implementation :: CPython",
    #     "Programming Language :: Cython",
    #     "Operating System :: POSIX :: Linux",
    #     "Operating System :: Microsoft :: Windows",
    # ],
    # keywords="truconsts, truly constants, constants",
)


if __name__ == '__main__':
    print(f"ROOT_DIR={ROOT_DIR}")
    print(f"PACKAGE_NAME={PACKAGE_NAME}")
    print(f"CYTHON_DIR_NAME={CYTHON_DIR_NAME}")
    print(f"C_FILES_DIRECTORY={C_FILES_DIRECTORY}")
    print(generate_extensions(PACKAGE_NAME, C_FILES_DIRECTORY))
