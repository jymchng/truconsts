#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE
from cpython.pystate cimport PyFrameObject
from cpython cimport PyObject
# from cpython cimport unaryfunc
import types


cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    # Functions
    
    # cdef object coro_await(PyCoroObject *coro)
    # cdef object coro_get_cr_await(PyCoroObject *coro, void *unused)
    # cdef object gen_iternext(PyGenObject *gen)
    # cdef int gen_is_coroutine(object o)

    # Types
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    ctypedef object (*unaryfunc)(object)

    # No need the `ctypedef struct PyTypeObject_PythonType:`
    ctypedef struct PyTypeObject_PythonType:
        setattrofunc tp_setattro
        getattrofunc tp_getattro

cdef extern from "genobject.h":
    int PyCoro_CheckExact(object o)
    object PyCoro_New(PyFrameObject*, object name, object qualname)
    int PyGen_Check(object o)
    int PyGen_CheckExact(object o)
    int PyCoro_CheckExact(object o)
    int PyAsyncGen_CheckExact(object o)
    object _PyCoro_GetAwaitableIter(object o)
    object _PyGen_yf(PyGenObject *o)

    ctypedef struct PyGenObject:
        pass

    ctypedef struct PyCoroObject:
        pass

    ctypedef struct PyCoroWrapper:
        PyCoroObject* cw_coroutine

    ctypedef struct PyAsyncGenObject:
        PyObject* ag_finalizer
        int ag_hooks_inited
        int ag_closed
        int ag_running_async

    ctypedef struct PyAsyncMethods:
        unaryfunc am_await
        unaryfunc am_aiter
        unaryfunc am_anext

    # PyAPI_DATA(PyTypeObject) PyComplex_Type; PyComplexObject
    ctypedef class types.AsyncGeneratorType [object PyAsyncGenObject]:
        # &async_gen_as_async,    <<< THIS                    /* tp_as_async */ <<< NOT THIS
        cdef PyAsyncMethods* async_gen_as_async
        
    # ctypedef struct PyAsyncGen_Type :
    #     PyAsyncMethods* tp_as_async

    ctypedef struct _PyAsyncGenASend_Type:
        PyAsyncMethods* tp_as_async

    # cdef _PyAsyncGenASend_Type PyAsyncGenSend_TypeType

    ctypedef struct _PyAsyncGenWrappedValue_Type:
        pass

    ctypedef struct _PyAsyncGenAThrow_Type:
        pass

    cdef PyTypeObject_PythonType PyType_Type

# cdef extern from "genobject.c": # to import pure C functions; 1. extern from "genobject.c" NOT "Python.h"
#     # declarations
#     cdef object coro_await(PyCoroObject *coro)
#     cdef object coro_get_cr_await(PyCoroObject *coro, void *unused)
#     cdef object gen_iternext(PyGenObject *gen)
#     cdef int gen_is_coroutine(object o)

# to enable export https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html?highlight=static#implementing-functions-in-c
    
