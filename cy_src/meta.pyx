#cython: language_level=3
# cython: c_string_type=unicode, c_string_encoding=ascii

from truconsts._types import Immutable, Lazy
from cpython cimport \
    PyObject_HasAttrString, \
    PyObject_GetAttrString, PyObject_CallFunction


cdef extern from "Python.h":
    # https://docs.python.org/3/c-api/typeobj.html#c.PyTypeObject
    ctypedef int (*setattrofunc)(type, object, object) except -1
    ctypedef object (*getattrofunc)(type, object)

    ctypedef struct PyTypeObject_PythonType "PyTypeObject":
        setattrofunc tp_setattro
        getattrofunc tp_getattro

    cdef PyTypeObject_PythonType PyType_Type


cdef class MetaForConstants(type):

    def __cinit__(mcls, str name, tuple bases, dict attrs):
        cdef const char* ANNOTATION_STRING = '__annotations__'

        mcls._immutable = set()
        mcls._lazy = set()
        mcls._attrs = set(filter(lambda k: not k.startswith(u"__"), attrs.keys()))
        mcls._init = False
        mcls._cache = dict()

        if not PyObject_HasAttrString(mcls, ANNOTATION_STRING):
            return
        annotations = PyObject_GetAttrString(mcls, ANNOTATION_STRING)
        for k, v in annotations.items():
            if isinstance(v, tuple):
                if Immutable in v:
                    mcls._immutable.add(k)
                if Lazy in v:
                    mcls._lazy.add(k)
            else:
                if v == Immutable:
                    mcls._immutable.add(k)
                elif v == Lazy:
                    mcls._lazy.add(k)
        mcls._init = True
        return
        
    def __setattr__(cls, object __name, object __value):
        cdef const char* ANNOTATION_STRING = '__annotations__'
        if __name not in cls._attrs:
            raise AttributeError(f"Cannot add `{__name}` class variable to `{cls.__name__}`")
        if not PyObject_HasAttrString(cls, ANNOTATION_STRING):
            PyType_Type.tp_setattro(cls, __name, __value)
            return
        if __name in cls._immutable:
            raise AttributeError(f"`{cls.__name__}.{__name}` cannot be mutated")
        PyType_Type.tp_setattro(cls, __name, __value)

    def __getattribute__(cls, __name: str):
        if not cls._init:
            return PyType_Type.tp_getattro(cls, __name)
        if __name in cls._lazy:
            func = PyType_Type.tp_getattro(cls, __name)
            _value = PyObject_CallFunction(func, NULL)
            PyType_Type.tp_setattro(cls, __name, _value)
            cls._lazy.remove(__name)
            return _value
        return PyType_Type.tp_getattro(cls, __name)
