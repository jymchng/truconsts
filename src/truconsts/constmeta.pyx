#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii
# Py_TPFLAGS_BASETYPE

from truconsts.annotations import Immutable, Cache, Yield
from libc.stdlib cimport free
from cpython cimport \
    PyObject_HasAttrString, PyTypeObject, \
    PyObject_GetAttrString, PyObject_CallFunction, PyObject_IsInstance, \
    Py_TYPE, PySet_New, PyTuple_New, Py_EQ, PyObject_RichCompareBool, PyDict_Items, PyMapping_HasKeyString, \
    Py_TPFLAGS_BASETYPE, PyCallable_Check, PyMapping_Keys, PyIter_Next, PyObject_GetIter, PySequence_Contains, \
    PyDict_SetItem, PyDict_GetItem, PyObject, PyDict_Contains, PyNumber_Int
from cpython.genobject cimport PyGen_CheckExact
import asyncio
from .cpy cimport PyCoro_CheckExact, PyType_Type, PyAsyncGen_CheckExact, \
    PyAsyncMethods, PyAsyncGen_Type

DEF _CACHE_ = 0b1100000
DEF _DISCARD_CACHE_ = 0b1011111
DEF _YIELD_ = 0b1010000
DEF _DISCARD_YIELD_ = 0b1101111
DEF _IMMUTABLE_ = 0b1001000
DEF _MUTABLE_ = 0b1110111
DEF _CACHE_AND_YIELD_ = _CACHE_ | _YIELD_

cdef class MetaForConstants(type):

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef Py_ssize_t set_init_size = 0
        cdef str k
        cdef dict annotations
        cdef int initial_bitflag
        cdef PyTypeObject* pytype_ptr

        mcls._attrs = PySet_New(PyTuple_New(set_init_size))
        mcls._init = False
        mcls._map = {}
        
        for k in PyMapping_Keys(attrs):
            if k.startswith('__'):
                continue
            PyDict_SetItem(mcls._map, k, 0b1000000)
        
        pytype_ptr = Py_TYPE(mcls)
        pytype_ptr.tp_flags &= ~Py_TPFLAGS_BASETYPE
        
        if not PyMapping_HasKeyString(attrs, ANNOTATION_STRING):
            return

        annotations = PyObject_GetAttrString(mcls, ANNOTATION_STRING)

        for (k, v) in PyDict_Items(annotations):
            initial_bitflag = 0b1000000
            if PyObject_IsInstance(v, tuple):
                if PySequence_Contains(v, Immutable):
                    initial_bitflag |= _IMMUTABLE_
                if PySequence_Contains(v, Cache):
                    initial_bitflag |= _CACHE_
                elif PySequence_Contains(v, Yield):
                    initial_bitflag |= _YIELD_
            else:
                if PyObject_RichCompareBool(v, Immutable, Py_EQ):
                    initial_bitflag |= _IMMUTABLE_
                elif PyObject_RichCompareBool(v, Cache, Py_EQ):
                    initial_bitflag |= _CACHE_
                elif PyObject_RichCompareBool(v, Yield, Py_EQ):
                    initial_bitflag |= _YIELD_
            PyDict_SetItem(mcls._map, k, initial_bitflag)

        mcls._init = True
        return
        
    def __setattr__(cls, str __name, object __value):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        cdef int bitflag
        cdef PyObject* prebitflag

        # CANNOT PUT ANY CODES IN FRONT OF THIS!!!
        if not cls._init:
            PyType_Type.tp_setattro(cls, __name, __value)
            return

        if not PyDict_Contains(cls._map, __name):
            raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        
        prebitflag = PyDict_GetItem(cls._map, __name)
        if prebitflag == NULL:
            raise RuntimeError(f"Unable to get the key `{__name}` from `{Py_TYPE(cls).tp_name, Py_TYPE(cls).tp_name}._map`")
        bitflag = PyNumber_Int(<object>prebitflag)

        # basic checks
        if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        if (bitflag & _IMMUTABLE_) == _IMMUTABLE_:
            raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated")

        PyDict_SetItem(cls._map, __name, 0b1000000)
        PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        cdef object _value
        cdef PyAsyncMethods *async_meths
        
        # CANNOT PUT ANY CODES IN FRONT OF THIS!!!
        if not cls._init:
            return PyType_Type.tp_getattro(cls, __name)

        cdef int bitflag
        cdef PyObject* prebitflag
        prebitflag = PyDict_GetItem(cls._map, __name)
        if prebitflag == NULL:
            return PyType_Type.tp_getattro(cls, __name)
        bitflag = PyNumber_Int(<object>prebitflag)

        if (bitflag & _CACHE_) == _CACHE_:
            _value = PyType_Type.tp_getattro(cls, __name)
            if PyCallable_Check(_value):
                _value = PyObject_CallFunction(_value, NULL)
                if PyCoro_CheckExact(_value):
                    loop = asyncio.get_event_loop()
                    _value = loop.run_until_complete(_value)
                    PyType_Type.tp_setattro(cls, __name, _value)
                    bitflag &= _DISCARD_CACHE_
                    PyDict_SetItem(cls._map, __name, bitflag)
                    return _value
                if PyGen_CheckExact(_value):
                    _value = PyObject_GetIter(_value)
                    _value = PyIter_Next(_value)
                    PyType_Type.tp_setattro(cls, __name, _value)
                    bitflag &= _DISCARD_CACHE_
                    PyDict_SetItem(cls._map, __name, bitflag)
                    return _value
                if PyAsyncGen_CheckExact(_value):
                    async_meths = PyAsyncGen_Type.tp_as_async
                    _value = async_meths.am_aiter(_value)
                    _value = async_meths.am_anext(_value)
                    loop = asyncio.get_event_loop()
                    _value = loop.run_until_complete(_value)
                    PyType_Type.tp_setattro(cls, __name, _value)
                    bitflag &= _DISCARD_CACHE_
                    PyDict_SetItem(cls._map, __name, bitflag)
                    return _value
                PyType_Type.tp_setattro(cls, __name, _value)
                bitflag &= _DISCARD_CACHE_
                PyDict_SetItem(cls._map, __name, bitflag)
                return _value
            PyType_Type.tp_setattro(cls, __name, _value)
            bitflag &= _DISCARD_CACHE_
            PyDict_SetItem(cls._map, __name, bitflag)
            return _value

        elif (bitflag & _YIELD_) == _YIELD_:
            _value = PyType_Type.tp_getattro(cls, __name)
            if PyCallable_Check(_value):
                _func = _value
                _value = PyObject_CallFunction(_value, NULL)
                if PyAsyncGen_CheckExact(_value):
                    # save the function to generate a new async generator
                    PyType_Type.tp_setattro(cls, __name, _func)
                    async_meths = PyAsyncGen_Type.tp_as_async
                    _value = async_meths.am_aiter(_value)
                    _value = async_meths.am_anext(_value)
                    loop = asyncio.get_event_loop()
                    _value = loop.run_until_complete(_value)
                    return _value
                if PyCoro_CheckExact(_value):
                    loop = asyncio.get_event_loop()
                    _value = loop.run_until_complete(_value)
                    return _value
                if PyGen_CheckExact(_value):
                    _value = PyObject_GetIter(_value)
                    # save the iterator
                    PyType_Type.tp_setattro(cls, __name, _value)
                    _value = PyIter_Next(_value)
                    return _value
            if PyAsyncGen_CheckExact(_value):
                async_meths = PyAsyncGen_Type.tp_as_async
                _value = async_meths.am_aiter(_value)
                _value = async_meths.am_anext(_value)
                loop = asyncio.get_event_loop()
                _value = loop.run_until_complete(_value)
                return _value
            if PyCoro_CheckExact(_value):
                    loop = asyncio.get_event_loop()
                    _value = loop.run_until_complete(_value)
                    return _value
            elif PyGen_CheckExact(_value):
                # next(generator) works, no need iter(generator) first
                _value = PyIter_Next(_value)
                return _value
            return _value
        return PyType_Type.tp_getattro(cls, __name)
