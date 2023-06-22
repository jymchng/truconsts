#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE

from truconsts._types import Immutable, Lazy, Async
from cpython cimport \
    PyObject_HasAttrString, \
    PyObject_GetAttrString, PyObject_CallFunction, PyObject_IsInstance, \
    Py_TYPE, PySet_Add, PySet_New, PyTuple_New, \
    PySequence_Contains, Py_EQ, PyObject_RichCompareBool, PyDict_Items, PySet_Discard, PyMapping_HasKeyString, \
    Py_TPFLAGS_BASETYPE
import asyncio
from .cpy cimport setattrofunc, getattrofunc, PyCoro_CheckExact, PyCallable_Check, PyTypeObject_PythonType, PyType_Type


cdef class MetaForConstants(type):

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef const char* CONST_AS_STRING = 'const_as'
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
        
        pytype_ptr = Py_TYPE(mcls)
        pytype_ptr.tp_flags &= ~Py_TPFLAGS_BASETYPE
        

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
        # basic checks
        if not PySequence_Contains(cls._attrs, __name):
            raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        if PySequence_Contains(cls._immutable, __name):
            raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated")

        # not-so-basic checks
        # mutability in python means anything goes
        if PyCoro_CheckExact(__value):
            PySet_Add(cls._async, __value)
        elif PyCallable_Check(__value):
            PySet_Add(cls._lazy, __value)
        elif PySequence_Contains(cls._async, __name):
            # for the case of assignment non-async value to variable that was previously async
            PySet_Discard(cls._async, __name)
        PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        cdef object _value

        if not cls._init:
            return PyType_Type.tp_getattro(cls, __name)
        if PySequence_Contains(cls._lazy, __name):
            func = PyType_Type.tp_getattro(cls, __name)
            _value = PyObject_CallFunction(func, NULL)
            PyType_Type.tp_setattro(cls, __name, _value)
            PySet_Discard(cls._lazy, __name) # value is already gotten from call to function
            return _value
        if PySequence_Contains(cls._async, __name):
            func = PyType_Type.tp_getattro(cls, __name)
            coroutine = PyObject_CallFunction(func, NULL) # get the coroutine
            loop = asyncio.get_event_loop()
            _value = loop.run_until_complete(coroutine) # resolve the future but not setting it as class variable
            return _value
        # assumption: lazy and async are mutually exclusive - guaranteed by exception raised with Async[Lazy]
        return PyType_Type.tp_getattro(cls, __name)
