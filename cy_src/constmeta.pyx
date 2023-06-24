#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE

from truconsts._types import Immutable, Cache, Yield
from libc.stdlib cimport free
from cpython cimport \
    PyObject_HasAttrString, \
    PyObject_GetAttrString, PyObject_CallFunction, PyObject_IsInstance, \
    Py_TYPE, PySet_Add, PySet_New, PyTuple_New, PyMem_Free, \
    PySet_Contains, Py_EQ, PyObject_RichCompareBool, PyDict_Items, PySet_Discard, PyMapping_HasKeyString, \
    Py_TPFLAGS_BASETYPE, PyCallable_Check, PyMapping_Keys, PyIter_Next, PyObject_GetIter, PySequence_Contains
from cpython.genobject cimport PyGen_CheckExact
import asyncio
from .cpy cimport PyCoro_CheckExact, PyType_Type, PyAsyncGen_CheckExact, \
    PyAsyncMethods, PyAsyncGen_Type
    # gen_is_coroutine, coro_get_cr_await, PyCoroObject, coro_await, gen_iternext


cdef class MetaForConstants(type):

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef Py_ssize_t set_init_size = 0
        cdef str k
        cdef dict annotations

        mcls._immutable = PySet_New(PyTuple_New(set_init_size))
        mcls._cache = PySet_New(PyTuple_New(set_init_size))
        mcls._yield = PySet_New(PyTuple_New(set_init_size))
        mcls._attrs = PySet_New(PyTuple_New(set_init_size))
        mcls._init = False
        
        for k in PyMapping_Keys(attrs):
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
                if PySequence_Contains(v, Cache):
                    PySet_Add(mcls._cache, k)
                elif PySequence_Contains(v, Yield):
                    PySet_Add(mcls._yield, k)
            else:
                if PyObject_RichCompareBool(v, Immutable, Py_EQ):
                    PySet_Add(mcls._immutable, k)
                elif PyObject_RichCompareBool(v, Cache, Py_EQ):
                    PySet_Add(mcls._cache, k)
                elif PyObject_RichCompareBool(v, Yield, Py_EQ):
                    PySet_Add(mcls._yield, k)

        mcls._init = True
        return
        
    def __setattr__(cls, str __name, object __value):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        
        # basic checks
        if not PySet_Contains(cls._attrs, __name):
            raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        if PySet_Contains(cls._immutable, __name):
            raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated")

        # once can set attribute, remove __name from the sets
        if PySet_Contains(cls._cache, __name):
            PySet_Discard(cls._cache, __name)
        if PySet_Contains(cls._yield, __name):
            PySet_Discard(cls._yield, __name)
        PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        cdef object _value
        # cdef PyAsyncGen_Type async_gen_type
        cdef PyAsyncMethods *async_meths
        
        if not cls._init:
            return PyType_Type.tp_getattro(cls, __name)

        if PySet_Contains(cls._cache, __name):
            _value = PyType_Type.tp_getattro(cls, __name)

            if PyCallable_Check(_value):
                _value = PyObject_CallFunction(_value, NULL)
                PyType_Type.tp_setattro(cls, __name, _value)
                PySet_Discard(cls._cache, __name)
                return _value

            if PyCoro_CheckExact(_value):
                loop = asyncio.get_event_loop()
                _value = loop.run_until_complete(_value)
                PyType_Type.tp_setattro(cls, __name, _value)
                PySet_Discard(cls._cache, __name)
                return _value

            if PyGen_CheckExact(_value):
                _value = PyObject_GetIter(_value)
                _value = PyIter_Next(_value)
                PyType_Type.tp_setattro(cls, __name, _value)
                PySet_Discard(cls._cache, __name)
                return _value

            if PyAsyncGen_CheckExact(_value):
                # value_type = Py_TYPE(_value)[0]
                # async_gen_type = <PyAsyncGen_Type?>value_type
                async_meths = PyAsyncGen_Type.tp_as_async
                _value = async_meths.am_aiter(_value)
                _value = async_meths.am_anext(_value)
                loop = asyncio.get_event_loop()
                _value = loop.run_until_complete(_value)
                PyType_Type.tp_setattro(cls, __name, _value)
                PySet_Discard(cls._cache, __name)
                return _value

        elif PySet_Contains(cls._yield, __name):
            _value = PyType_Type.tp_getattro(cls, __name)
            if PyCallable_Check(_value):
                _value = PyObject_CallFunction(_value, NULL)
                return _value

            if PyCoro_CheckExact(_value):
                loop = asyncio.get_event_loop()
                _value = loop.run_until_complete(_value)
                return _value

            if PyGen_CheckExact(_value):
                _value = PyObject_GetIter(_value)
                _value = PyIter_Next(_value)
                return _value

            if PyAsyncGen_CheckExact(_value):
                # async_meths = <PyAsyncMethods*?>AsyncGeneratorType.async_gen_as_async
                # _value = async_meths.am_aiter(_value)
                # _value = async_meths.am_anext(_value)
                # loop = asyncio.get_event_loop()
                # _value = loop.run_until_complete(_value)
                # return _value
                async_meths = PyAsyncGen_Type.tp_as_async
                _value = async_meths.am_aiter(_value)
                _value = async_meths.am_anext(_value)
                loop = asyncio.get_event_loop()
                _value = loop.run_until_complete(_value)
                return _value
        return PyType_Type.tp_getattro(cls, __name)
