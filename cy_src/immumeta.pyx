#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE

from truconsts._types import Immutable, Lazy, Async, Mutable
from cpython cimport \
    PyObject_HasAttrString, \
    PyObject_GetAttrString, PyObject_CallFunction, PyObject_IsInstance, \
    Py_TYPE, PySet_Add, PySet_New, PyTuple_New, PySequence_Length, PyTuple_Size, \
    PySequence_Contains, Py_EQ, PyObject_RichCompareBool, PyDict_Items, PySet_Discard, PyMapping_HasKeyString, \
    Py_TPFLAGS_BASETYPE
import asyncio


cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)
    int PyCoro_CheckExact(object o)
    int PyCallable_Check(object o)

    ctypedef struct PyTypeObject_PythonType "PyTypeObject":
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    cdef PyTypeObject_PythonType PyType_Type


cdef class MetaForImmutables(type):

    def __init_subclass__(cls, tuple const_as=()) -> None:
        if PyTuple_Size(const_as) != 0:
            raise ValueError(f"`{cls.__name__}` which inherits from `Immutable` must not have `const_as` as a non-empty tuple parameter")
            # if PySequence_Contains(const_as, Lazy) and PySequence_Contains(const_as, Async):
            #     raise ValueError(f"`const_as` tuple cannot contain both `Lazy` and `Async`")
            # if PySequence_Contains(const_as, Mutable) or PySequence_Contains(const_as, Immutable):
            #     raise ValueError(f"`const_as` tuple cannot contain `Mutable` and/or `Immutable` cannot be in `const_as` since `{cls.__name__}` subclasses `Immutable`")
        cls._const_as = const_as
        cls._init = False
        return cls

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef const char* CONST_AS_STRING = 'const_as'
        cdef Py_ssize_t set_init_size = 0
        cdef str k
        cdef dict annotations

        mcls._init = True

        mcls._lazy = PySet_New(PyTuple_New(set_init_size))
        mcls._async = PySet_New(PyTuple_New(set_init_size))
        mcls._attrs = PySet_New(PyTuple_New(set_init_size))
        # put MethodType here = (MetaForImmutables.__init_subclass__)

        if (PySequence_Contains(bases, Lazy) and PySequence_Contains(bases, Async)) or PySequence_Contains(bases, Mutable):
            raise ValueError(f"Cannot inherit both `Lazy` and `Async` or from `Mutable` when `{name}` subclasses `Immutable`")
        
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
                # if PySequence_Contains(v, Immutable):
                #     PySet_Add(mcls._immutable, k)
                if PySequence_Contains(v, Lazy):
                    PySet_Add(mcls._lazy, k)
                elif PySequence_Contains(v, Async):
                    PySet_Add(mcls._async, k)
            else:
                # if PyObject_RichCompareBool(v, Immutable, Py_EQ):
                #     PySet_Add(mcls._immutable, k)
                if PyObject_RichCompareBool(v, Lazy, Py_EQ):
                    PySet_Add(mcls._lazy, k)
                elif PyObject_RichCompareBool(v, Async, Py_EQ):
                    PySet_Add(mcls._async, k)

        return
        
    def __setattr__(cls, str __name, object __value):
        # cdef const char* ANNOTATION_STRING = '__annotations__'
        # basic checks
        # if not PySequence_Contains(cls._attrs, __name):
        #     raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        # if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
        #     PyType_Type.tp_setattro(cls, __name, __value)
        #     return
        # if PySequence_Contains(cls._immutable, __name):
        if PyObject_RichCompareBool(__name, '__init_subclass__', Py_EQ) and PyObject_RichCompareBool(__value, MetaForImmutables.__init_subclass__, Py_EQ):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated, setting value = {__value==MetaForImmutables.__init_subclass__} with name = {__value.__name__}")

        # not-so-basic checks
        # mutability in python means anything goes
        # if PyCoro_CheckExact(__value):
        #     PySet_Add(cls._async, __value)
        # elif PyCallable_Check(__value):
        #     PySet_Add(cls._lazy, __value)
        # elif PySequence_Contains(cls._async, __name):
        #     # for the case of assignment non-async value to variable that was previously async
        #     PySet_Discard(cls._async, __name)
        # PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        cdef object _value

        if cls._init:
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
