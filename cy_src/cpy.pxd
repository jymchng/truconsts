#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE
from cpython.pystate cimport PyFrameObject



cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    # Functions
    int PyCoro_CheckExact(object o)
    object PyCoro_New(PyFrameObject*, object name, object qualname)
    int PyGen_Check(object o)
    int PyGen_CheckExact(object o)
    int PyCoro_CheckExact(object o)
    int PyAsyncGen_CheckExact(object o)
    object _PyCoro_GetAwaitableIter(object o)

    # Types
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    ctypedef struct PyTypeObject_PythonType:
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    ctypedef struct PyGenObject:
        pass

    ctypedef struct PyCoroObject:
        pass

    ctypedef struct PyCoroWrapper:
        PyCoroObject *cw_coroutine

    ctypedef struct PyAsyncGenObject:
        pass

    cdef PyTypeObject_PythonType PyType_Type

# cdef extern from "genobject.c": # to import pure C functions; 1. extern from "genobject.c" NOT "Python.h"
#     # declarations
#     cdef object coro_await(PyCoroObject *coro)
#     cdef object coro_get_cr_await(PyCoroObject *coro, void *unused)
#     cdef object gen_iternext(PyGenObject *gen)
#     cdef int gen_is_coroutine(object o)

# to enable export https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html?highlight=static#implementing-functions-in-c
    
