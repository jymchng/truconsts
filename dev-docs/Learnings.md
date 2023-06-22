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

# Learning Four

1. All `.c` files in Python are accessible via
2. In Cython, when declaring functions, all `PyObject *` can be replaced by `object`, all other pointer objects have to be declared as pointers. E.g.

In `genobject.pxd`
```
object PyGen_NewWithQualName(PyFrameObject *frame, object name, object qualname)
# Return value: New reference.
# Create and return a new generator object based on the frame object, with
# __name__ and __qualname__ set to name and qualname. A reference to frame
# is stolen by this function. The frame argument must not be NULL.
```
In `genobject.c` (not that it is not `genobject.h`, meaning all functions in a `.c` file are exposed)
```
PyObject *
PyGen_NewWithQualName(PyFrameObject *f, PyObject *name, PyObject *qualname)
{
    return gen_new_with_qualname(&PyGen_Type, f, name, qualname);
}
```

Another example...
In `object.pxd`
```
ctypedef struct PyTypeObject:
    const char* tp_name
    const char* tp_doc
    Py_ssize_t tp_basicsize
    Py_ssize_t tp_itemsize
    Py_ssize_t tp_dictoffset
    unsigned long tp_flags

    newfunc tp_new
    destructor tp_dealloc
    traverseproc tp_traverse
    inquiry tp_clear
    freefunc tp_free

    ternaryfunc tp_call
    hashfunc tp_hash
    reprfunc tp_str
    reprfunc tp_repr

    cmpfunc tp_compare
    richcmpfunc tp_richcompare

    PyTypeObject* tp_base
    PyObject* tp_dict

    descrgetfunc tp_descr_get
    descrsetfunc tp_descr_set
```

In `typestruct.h`
```
typedef struct _typeobject {
    PyObject_VAR_HEAD
    const char *tp_name; /* For printing, in format "<module>.<name>" */
    Py_ssize_t tp_basicsize, tp_itemsize; /* For allocation */

    /* Methods to implement standard operations */

    destructor tp_dealloc;
    Py_ssize_t tp_vectorcall_offset;
    getattrfunc tp_getattr;
    setattrfunc tp_setattr;
    PyAsyncMethods *tp_as_async; /* formerly known as tp_compare (Python 2)
                                    or tp_reserved (Python 3) */
    reprfunc tp_repr;

    /* Method suites for standard classes */

    PyNumberMethods *tp_as_number;
    PySequenceMethods *tp_as_sequence;
    PyMappingMethods *tp_as_mapping;

    /* More standard operations (here for binary compatibility) */

    hashfunc tp_hash;
    ternaryfunc tp_call;
    reprfunc tp_str;
    getattrofunc tp_getattro;
    setattrofunc tp_setattro;

    /* Functions to access object as input/output buffer */
    PyBufferProcs *tp_as_buffer;

    /* Flags to define presence of optional/expanded features */
    unsigned long tp_flags;

    const char *tp_doc; /* Documentation string */

    /* Assigned meaning in release 2.0 */
    /* call function for all accessible objects */
    traverseproc tp_traverse;

    /* delete references to contained objects */
    inquiry tp_clear;

    /* Assigned meaning in release 2.1 */
    /* rich comparisons */
    richcmpfunc tp_richcompare;

    /* weak reference enabler */
    Py_ssize_t tp_weaklistoffset;

    /* Iterators */
    getiterfunc tp_iter;
    iternextfunc tp_iternext;

    /* Attribute descriptor and subclassing stuff */
    struct PyMethodDef *tp_methods;
    struct PyMemberDef *tp_members;
    struct PyGetSetDef *tp_getset;
    // Strong reference on a heap type, borrowed reference on a static type
    struct _typeobject *tp_base;
    PyObject *tp_dict;
    descrgetfunc tp_descr_get;
    descrsetfunc tp_descr_set;
    Py_ssize_t tp_dictoffset;
    initproc tp_init;
    allocfunc tp_alloc;
    newfunc tp_new;
    freefunc tp_free; /* Low-level free-memory routine */
    inquiry tp_is_gc; /* For PyObject_IS_GC */
    PyObject *tp_bases;
    PyObject *tp_mro; /* method resolution order */
    PyObject *tp_cache;
    PyObject *tp_subclasses;
    PyObject *tp_weaklist;
    destructor tp_del;

    /* Type attribute cache version tag. Added in version 2.6 */
    unsigned int tp_version_tag;

    destructor tp_finalize;
    vectorcallfunc tp_vectorcall;

    /* bitset of which type-watchers care about this type */
    char tp_watched;
} PyTypeObject;
```

Sometimes if no need to declare attributes, can just `pass`, like so:
```
    ctypedef struct PyInterpreterState:
        pass

    ctypedef struct PyThreadState:
        pass

    ctypedef struct PyFrameObject:
        pass
```

# Learning Five

`Py_UNUSED` definition is here: https://github.com/python/cpython/blob/13237a2da846efef9ce9b93fd4bcfebd49933568/Include/pymacro.h#L114

If type of argument `Py_UNUSED` declared in function is `void *`, can simple use `NULL` as a parameter.

Example:
coro_get_cr_await
Function definition: https://github.com/python/cpython/blob/13237a2da846efef9ce9b93fd4bcfebd49933568/Objects/genobject.c#L1093
How it is used: https://github.com/python/cpython/blob/13237a2da846efef9ce9b93fd4bcfebd49933568/Objects/genobject.c#L1093

# Learning Six

The `.h` header file contains forward-declarations e.g. https://github.com/python/cpython/blob/13237a2da846efef9ce9b93fd4bcfebd49933568/Include/cpython/genobject.h#LL75C24-L75C38 for the definitions in `.c` source file, e.g. https://github.com/python/cpython/blob/13237a2da846efef9ce9b93fd4bcfebd49933568/Objects/genobject.c#L1664

# Learning Seven

![Alt text](cyimplfuncfromc.png)

To import a `.c` into Cython, must do the following:

1. Must be `cdef extern from "sage/graphs/cliquer/cl.c":` `.c` instead of `cdef extern from "sage/graphs/cliquer/cl.h":` `.h`
2. Must add `cdef` in front of all declarations

Example: https://github.com/sagemath/sage/blob/3230f00aeb49802f99b0a3b76e770fa9d628c4e1/src/sage/graphs/cliquer.pyx#L38
```
cdef extern from "sage/graphs/cliquer/cl.c":
    cdef int sage_clique_max(graph_t *g, int ** list_of_vertices)
    cdef int sage_all_clique_max(graph_t *g, int ** list_of_vertices)
    cdef int sage_clique_number(graph_t *g)
    cdef int sage_find_all_clique(graph_t *g, int ** list_of_vertices, int min_size, int max_size)
```
Reference: https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html?highlight=static#implementing-functions-in-c

```
static int
gen_is_coroutine(PyObject *o)
{
    if (PyGen_CheckExact(o)) {
        PyCodeObject *code = (PyCodeObject *)((PyGenObject*)o)->gi_code;
        if (code->co_flags & CO_ITERABLE_COROUTINE) {
            return 1;
        }
    }
    return 0;
}
```

```
static PyObject *
coro_get_cr_await(PyCoroObject *coro, void *Py_UNUSED(ignored))
{
    PyObject *yf = _PyGen_yf((PyGenObject *) coro);
    if (yf == NULL)
        Py_RETURN_NONE;
    return yf;
}
```