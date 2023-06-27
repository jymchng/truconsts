#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
from cpython.pystate cimport PyFrameObject
from cpython cimport PyObject


cdef extern from "Python.h":
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    ctypedef object (*unaryfunc)(object)

    ctypedef struct PyTypeObject:
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    cdef PyTypeObject PyType_Type

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

    ctypedef struct PyAsyncGen_PythonType:
        PyAsyncMethods *tp_as_async

    cdef PyAsyncGen_PythonType PyAsyncGen_Type

    ctypedef struct _PyAsyncGenASend_Type:
        PyAsyncMethods* tp_as_async

    cdef PyTypeObject* _PyAsyncGenWrappedValue_Type

    cdef PyTypeObject* _PyAsyncGenAThrow_Type
    
