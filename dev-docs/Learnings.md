# Learning One

Always `git remote` the repo first!

# Learning Two

The following is necessary in `pyproject.toml` if want to have `cy_src` containing cython files and a separate directory `truconsts` containing python files.

```
packages = ["truconsts", "cy_src"]
```

# Learning Three

Wasted a lot of time on this because thought got bug, but the bug is with PYPI Test.

Need to include `--extra-index-url`, like so:

```
pip install -U --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple truconsts
```

Or else will have error, like so:

```
$ pip install -i https://test.pypi.org/simple/ truconsts==0.0.5
Looking in indexes: https://test.pypi.org/simple/
Collecting truconsts==0.0.5
  Using cached https://test-files.pythonhosted.org/packages/c1/05/7a8f01fdc68e1783561d3f667a7e4b61b3cc04616b7774d7fc338e0ccc53/truconsts-0.0.5.tar.gz (49 kB)
  Installing build dependencies ... error
  error: subprocess-exited-with-error

  × pip subprocess to install build dependencies did not run successfully.
  │ exit code: 1
  ╰─> [6 lines of output]
      Looking in indexes: https://test.pypi.org/simple/
      ERROR: Could not find a version that satisfies the requirement setuptools (from versions: none)
      ERROR: No matching distribution found for setuptools
     
      [notice] A new release of pip is available: 23.0.1 -> 23.1.2
      [notice] To update, run: python.exe -m pip install --upgrade pip
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
error: subprocess-exited-with-error

× pip subprocess to install build dependencies did not run successfully.
│ exit code: 1
╰─> See above for output.

note: This error originates from a subprocess, and is likely not a problem with pip.

[notice] A new release of pip is available: 23.0.1 -> 23.1.2
[notice] To update, run: python.exe -m pip install --upgrade pip
```