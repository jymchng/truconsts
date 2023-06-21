#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii

from truconsts._types import Immutable, Lazy, Async
from cpython cimport \
    PyObject_HasAttrString, \
    PyObject_GetAttrString, PyObject_CallFunction, PyTypeObject, PyObject_IsInstance, \
    PyObject_Type, Py_TPFLAGS_BASETYPE, PySet_Add, PySet_New, PyTuple_New, \
    PySequence_Contains, Py_EQ, PyObject_RichCompareBool, PyDict_Items, PySet_Discard, PyMapping_HasKeyString, \
    unaryfunc, Py_XINCREF, PyObject, Py_TYPE, PySet_Pop
import asyncio


cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    # ctypedef PySendResult (*sendfunc)(PyObject*, PyObject*, PyObject**)
    # int PyCoro_CheckExact(object o)

    # typedef struct {
    #     unaryfunc am_await;
    #     unaryfunc am_aiter;
    #     unaryfunc am_anext;
    #     sendfunc am_send;
    # } PyAsyncMethods;
    # https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html#styles-of-struct-union-and-enum-declaration
    # https://docs.python.org/3/c-api/typeobj.html?highlight=await#async-object-structures
    ctypedef struct PyAsyncMethods:
        unaryfunc am_await
        unaryfunc am_aiter
        unaryfunc am_anext
        # sendfunc am_send

    ctypedef struct PyTypeObject_PythonType "PyTypeObject":
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    cdef PyTypeObject_PythonType PyType_Type


cdef class MetaForConstants(type):

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef Py_ssize_t set_init_size = 0
        cdef str k
        cdef dict annotations

        mcls._immutable = PySet_New(PyTuple_New(set_init_size))
        mcls._lazy = PySet_New(PyTuple_New(set_init_size))
        mcls._async = PySet_New(PyTuple_New(set_init_size))
        mcls._attrs = PySet_New(PyTuple_New(set_init_size))
        mcls._init = False
        
        for k in attrs.keys():
            if k.startswith('__'):
                continue
            PySet_Add(mcls._attrs, k)
        
        # pytype_ptr = Py_TYPE(mcls)
        # clear the bit `Py_TPFLAGS_BASETYPE` if you don't want this type to be inheritable
        # pytype_ptr.tp_flags &= ~Py_TPFLAGS_BASETYPE

        if not PyMapping_HasKeyString(attrs, ANNOTATION_STRING):
            return

        annotations = PyObject_GetAttrString(mcls, ANNOTATION_STRING)

        for (k, v) in PyDict_Items(annotations):
            if PyObject_IsInstance(v, tuple):
                if PySequence_Contains(v, Immutable):
                    PySet_Add(mcls._immutable, k)
                if PySequence_Contains(v, Lazy):
                    PySet_Add(mcls._lazy, k)
                elif PySequence_Contains(v, Async):
                    PySet_Add(mcls._async, k)
            else:
                if PyObject_RichCompareBool(v, Immutable, Py_EQ):
                    PySet_Add(mcls._immutable, k)
                elif PyObject_RichCompareBool(v, Lazy, Py_EQ):
                    PySet_Add(mcls._lazy, k)
                elif PyObject_RichCompareBool(v, Async, Py_EQ):
                    PySet_Add(mcls._async, k)

        mcls._init = True
        return
        
    def __setattr__(cls, str __name, object __value):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        if not PySequence_Contains(cls._attrs, __name):
            raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        if PySequence_Contains(cls._immutable, __name):
            raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated")
        if PySequence_Contains(cls._async, __name):
            PySet_Discard(cls._async, __name)
        PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        cdef object _value

        if not cls._init:
            return PyType_Type.tp_getattro(cls, __name)
        if PySequence_Contains(cls._lazy, __name):
            func = PyType_Type.tp_getattro(cls, __name)
            _value = PyObject_CallFunction(func, NULL)
            # if PyCoro_CheckExact(_value):
            #     async_meths_struct = PyType_Type.tp_as_async
            #     if async_meths_struct == NULL:
            #         raise TypeError(f"`async_meths_struct` is a NULL pointer; `{cls.__name__}.{__name}` is marked as `Lazy`")
            #     _value = async_meths_struct.am_await(_value)
            #     PyMem_Free(async_meths_struct)
            PyType_Type.tp_setattro(cls, __name, _value)
            PySet_Discard(cls._lazy, __name)
            return _value
        if PySequence_Contains(cls._async, __name):
            func = PyType_Type.tp_getattro(cls, __name)
            coroutine = PyObject_CallFunction(func, NULL)
            loop = asyncio.get_event_loop()
            _value = loop.run_until_complete(coroutine)
            return _value
        return PyType_Type.tp_getattro(cls, __name)
